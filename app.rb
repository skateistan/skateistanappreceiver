require 'bundler/setup'
require 'sinatra' unless defined?(Sinatra)
require 'yaml' if development?
require 'highrise'
require 'createsend'
require 'omniauth-createsend'

configure do
  require 'newrelic_rpm' if production?
  config = YAML.load_file('config.yaml') if !production?

  HIGHRISE_API_TOKEN = (production? ? ENV['HIGHRISE_API_TOKEN'] : config['HIGHRISE_API_TOKEN']) unless defined?(HIGHRISE_API_TOKEN)
  HIGHRISE_URL = (production? ? ENV['HIGHRISE_URL'] : config['HIGHRISE_URL']) unless defined?(HIGHRISE_URL)
  Highrise::Base.format = :xml
  Highrise::Base.site = HIGHRISE_URL
  Highrise::Base.user = HIGHRISE_API_TOKEN

  CAMPAIGN_MONITOR_CLIENT_ID = (production? ? ENV['CAMPAIGN_MONITOR_CLIENT_ID'] : config['CAMPAIGN_MONITOR_CLIENT_ID']) unless defined?(CAMPAIGN_MONITOR_CLIENT_ID)
  CAMPAIGN_MONITOR_CLIENT_SECRET = (production? ? ENV['CAMPAIGN_MONITOR_CLIENT_SECRET'] : config['CAMPAIGN_MONITOR_CLIENT_SECRET']) unless defined?(CAMPAIGN_MONITOR_CLIENT_SECRET)
  CAMPAIGN_MONITOR_ACCESS_TOKEN = (production? ? ENV['CAMPAIGN_MONITOR_ACCESS_TOKEN'] : config['CAMPAIGN_MONITOR_ACCESS_TOKEN']) unless defined?(CAMPAIGN_MONITOR_ACCESS_TOKEN)
  CAMPAIGN_MONITOR_REFRESH_TOKEN = (production? ? ENV['CAMPAIGN_MONITOR_REFRESH_TOKEN'] : config['CAMPAIGN_MONITOR_REFRESH_TOKEN']) unless defined?(CAMPAIGN_MONITOR_REFRESH_TOKEN)
  CAMPAIGN_MONITOR_LIST_ID = (production? ? ENV['CAMPAIGN_MONITOR_LIST_ID'] : config['CAMPAIGN_MONITOR_LIST_ID']) unless defined?(CAMPAIGN_MONITOR_LIST_ID)
end

use OmniAuth::Builder do
  provider :createsend, CAMPAIGN_MONITOR_CLIENT_ID, CAMPAIGN_MONITOR_CLIENT_SECRET,
    :scope => 'ManageLists,ImportSubscribers'
end

# The user goes to /auth/createsend to initiate the OAuth exchange.
# After the user is authenticated, they are redirected here.
get '/auth/:provider/callback' do
  access_token = request.env['omniauth.auth']['credentials']['token']
  refresh_token = request.env['omniauth.auth']['credentials']['refresh_token']

  response = "<pre>"
  response << "You're authenticated - Here's what you need:<br/><br/>"
  response << "access token: #{access_token}<br/>"
  response << "refresh token: #{refresh_token}<br/>"
  response << "</pre>"
  response
end

get '/' do
  "Skateistan online application receiver."
end

def add_cm_subscriber(email, name, custom_fields)
  auth = {
    :access_token => CAMPAIGN_MONITOR_ACCESS_TOKEN,
    :refresh_token => CAMPAIGN_MONITOR_REFRESH_TOKEN
  }
  begin
    tries ||= 2
    CreateSend::Subscriber.add(
      auth, CAMPAIGN_MONITOR_LIST_ID, email, name, custom_fields, true)
    rescue CreateSend::ExpiredOAuthToken => eot
      access_token, expires_in, refresh_token =
        CreateSend::CreateSend.new(auth).refresh_token
      ENV['CAMPAIGN_MONITOR_ACCESS_TOKEN'] = access_token
      auth[:access_token] = access_token
      retry unless (tries -= 1).zero?
      p "Error: #{eot}"
  end
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
  add_cm_subscriber email, name, custom_fields

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
  add_cm_subscriber email, name, custom_fields

  # Respond with 201 Created, and set the body as the applicant's Highrise URL
  status 201
  body "#{HIGHRISE_URL}/people/#{person.id}"
end