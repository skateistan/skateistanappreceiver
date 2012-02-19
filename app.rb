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
  age = params['age']
  address = params['address']
  skate = params['skate']
  interested = params['interested']
  help = params['help']
  hours = params['hours']
  months = params['months']
  
  person = Highrise::Person.create :first_name => first_name, :last_name => last_name,
    :contact_data => {
      :email_addresses => [
        { :address => email, :location => 'Home' }
      ]
    }
  person.tag! "remote applicant"
  
  note = "Remote Volunteer Application: \n\n ..."
  note += "Address:\n#{address}\n\n"
  note += "Age: #{age}\n\n"
  note += "Are you a skateboarder? #{skate}\n\n"
  note += "Why are you interested in the Skateistan project?\n#{interested}\n\n"
  note += "How could you help Skateistan from your current location?\n#{help}\n\n"
  note += "How many hours a week could you to dedicate to a remote volunteer position?\n#{hours}\n\n"
  note += "How many months could you potentially dedicate to a remote volunteer position?\n#{months}\n"

  person.add_note :body => note

  # Respond with 201 Created, and set the body as the applicant's Highrise URL
  status 201
  body "#{HIGHRISE_URL}/people/#{person.id}"
end