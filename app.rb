require 'bundler/setup'
require 'sinatra' unless defined?(Sinatra)
require "sinatra/reloader" if development?
require 'yaml' if development?
require 'highrise'
require 'createsend'

configure do
  require 'newrelic_rpm' if production?
  config = YAML.load_file('config.yaml') if !production?

  HIGHRISE_API_TOKEN = (production? ? ENV['HIGHRISE_API_TOKEN'] : config['HIGHRISE_API_TOKEN']) unless defined?(HIGHRISE_API_TOKEN)
  HIGHRISE_URL = (production? ? ENV['HIGHRISE_URL'] : config['HIGHRISE_URL']) unless defined?(HIGHRISE_URL)
  Highrise::Base.format = :xml
  Highrise::Base.site = HIGHRISE_URL
  Highrise::Base.user = HIGHRISE_API_TOKEN

  CAMPAIGN_MONITOR_API_KEY = (production? ? ENV['CAMPAIGN_MONITOR_API_KEY'] : config['CAMPAIGN_MONITOR_API_KEY']) unless defined?(CAMPAIGN_MONITOR_API_KEY)
  CAMPAIGN_MONITOR_LIST_ID = (production? ? ENV['CAMPAIGN_MONITOR_LIST_ID'] : config['CAMPAIGN_MONITOR_LIST_ID']) unless defined?(CAMPAIGN_MONITOR_LIST_ID)
end

get '/' do
  "<!--Skateistan application receiver. Move along. :) -->"
end

# Receive intern application
post '/a/?' do
  name = params['name']
  email = params['email']
  note = params['note']
  skills = params['skills']

  person = Highrise::Person.create :name => name,
    :contact_data => {
      :email_addresses => [
        { :address => email, :location => 'Home' }
      ]
    },
    :subject_datas => [
      { :subject_field_id => 535652, :value => skills } # Skills
    ]
  person.tag! "intern applicant"
  person.add_note :body => note

  custom_fields = [{ :Key => 'type', :Value => 'ia' }]
  CreateSend::Subscriber.add(
    {:api_key => CAMPAIGN_MONITOR_API_KEY}, CAMPAIGN_MONITOR_LIST_ID,
    email, name, custom_fields, true)

  # Respond with 201 Created, and set the body as the applicant's Highrise URL
  status 201
  body "#{HIGHRISE_URL}/people/#{person.id}"
end

# Receive remote volunteer application
post '/rva/?' do
  name = params['name']
  email = params['email']
  note = params['note']
  
  person = Highrise::Person.create :name => name,
    :contact_data => {
      :email_addresses => [
        { :address => email, :location => 'Home' }
      ]
    }
  person.tag! "remote applicant"
  person.add_note :body => note

  custom_fields = [{ :Key => 'type', :Value => 'rva' }]
  CreateSend::Subscriber.add(
    {:api_key => CAMPAIGN_MONITOR_API_KEY}, CAMPAIGN_MONITOR_LIST_ID,
    email, name, custom_fields, true)

  # Respond with 201 Created, and set the body as the applicant's Highrise URL
  status 201
  body "#{HIGHRISE_URL}/people/#{person.id}"
end