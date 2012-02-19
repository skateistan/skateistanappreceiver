require 'bundler/setup'
require 'sinatra' unless defined?(Sinatra)
require "sinatra/reloader" if development?
require 'yaml' if development?
require 'highrise'

configure do
  config = YAML.load_file('config.yaml') if !production?
  HIGHRISE_API_TOKEN = (production? ? ENV['HIGHRISE_API_TOKEN'] : config['HIGHRISE_API_TOKEN']) unless defined?(HIGHRISE_API_TOKEN)
  HIGHRISE_URL = (production? ? ENV['HIGHRISE_URL'] : config['HIGHRISE_URL']) unless defined?(HIGHRISE_URL)
  Highrise::Base.site = HIGHRISE_URL
  Highrise::Base.user = HIGHRISE_API_TOKEN
end

# Receive application
post '/a/?' do

  # TODO: Receive application...

end

# Receive remote volunteer application
post '/rva/?' do
  name = params['name']
  email = params['email']
  
  p name
  p email
  
  person = Highrise::Person.create :name => name,
    :contact_data => {
      :email_addresses => [
        { :address => email, :location => 'Home' }
      ]
    }
  
  # TODO: Add a note with the full contents of the application
  
end