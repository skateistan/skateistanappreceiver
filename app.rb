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
  first_name = params['firstname']
  last_name = params['lastname']
  email = params['email']
  
  person = Highrise::Person.create :first_name => first_name, :last_name => last_name

  puts "tag as applicant"

  person.tag! "applicant"

  puts "tagged as applicant"
  
  # Email whoever...
  
  # TODO: Add a note with the full contents of the application
  
end