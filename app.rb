require 'bundler/setup'
require 'sinatra' unless defined?(Sinatra)
require "sinatra/reloader" if development?
require 'yaml' if development?
require 'highrise'

configure do
  config = YAML.load_file('config.yaml') if !production?
  HIGHRISE_API_TOKEN = (production? ? ENV['HIGHRISE_API_TOKEN'] : config['HIGHRISE_API_TOKEN']) unless defined?(HIGHRISE_API_TOKEN)
  HIGHRISE_URL = (production? ? ENV['HIGHRISE_URL'] : config['HIGHRISE_URL']) unless defined?(HIGHRISE_URL)
  Highrise::Base.format = :xml
  Highrise::Base.site = HIGHRISE_URL
  Highrise::Base.user = HIGHRISE_API_TOKEN
end

# Receive application
post '/a/?' do

  # TODO: Receive application...

end

# Receive remote volunteer application
post '/rva/?' do
  first_name = params['firstname']
  last_name = params['lastname']
  email = params['email']
  
  person = Highrise::Person.create :first_name => first_name, :last_name => last_name,
    :contact_data => {
      :email_addresses => [
        { :address => email, :location => 'Home' }
      ]
    }
  person.tag! "applicant"

  person.add_note :body => "Remote Volunteer Application: \n\n ..."

  # Respond with 201 Created, and set the body as the applicant's Highrise URL
  status 201
  body "#{HIGHRISE_URL}/people/#{person.id}"
  
end