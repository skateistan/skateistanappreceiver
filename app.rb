require "bundler/setup"
require "sinatra" unless defined?(Sinatra)
require "createsend"
require "omniauth-createsend"
require "heroku-api"

configure do
  require "newrelic_rpm" if production?
end

use Rack::Session::Cookie
use OmniAuth::Builder do
  provider :createsend, ENV["CAMPAIGN_MONITOR_CLIENT_ID"],
    ENV["CAMPAIGN_MONITOR_CLIENT_SECRET"],
    :scope => "ManageLists,ImportSubscribers"
end

# The user goes to /auth/createsend to initiate the OAuth exchange.
# After the user is authenticated, they are redirected here.
get "/auth/:provider/callback" do
  access_token = request.env["omniauth.auth"]["credentials"]["token"]
  refresh_token = request.env["omniauth.auth"]["credentials"]["refresh_token"]

  response = "<pre>"
  response << "You're authenticated - here's what you need:<br/><br/>"
  response << "access token: #{access_token}<br/>"
  response << "refresh token: #{refresh_token}<br/>"
  response << "</pre>"
  response
end

get "/" do
  "Skateistan online application receiver."
end

def add_cm_subscriber(email, name, custom_fields)
  auth = {
    :access_token => ENV["CAMPAIGN_MONITOR_ACCESS_TOKEN"],
    :refresh_token => ENV["CAMPAIGN_MONITOR_REFRESH_TOKEN"]
  }
  begin
    tries ||= 2
    CreateSend::Subscriber.add(
      auth, ENV["CAMPAIGN_MONITOR_LIST_ID"], email, name, custom_fields, true)
    rescue CreateSend::ExpiredOAuthToken => eot
      access_token, expires_in, refresh_token =
        CreateSend::CreateSend.refresh_access_token auth[:refresh_token]
      # Doing `ENV["CAMPAIGN_MONITOR_ACCESS_TOKEN"] = access_token` here
      # would not persist the environment variable, which would mean that
      # we would end up refreshing the access token for every single request.
      # So instead, we use the Heroku API to set CAMPAIGN_MONITOR_ACCESS_TOKEN.
      # Persisting CAMPAIGN_MONITOR_ACCESS_TOKEN means that we only need to
      # refresh tokens when the current access token has expired.
      heroku = Heroku::API.new # Assumes ENV["HEROKU_API_KEY"] is set
      heroku.put_config_vars(
        "skateistanappreceiver",
        "CAMPAIGN_MONITOR_ACCESS_TOKEN" => access_token)
      auth[:access_token] = access_token
      retry unless (tries -= 1).zero?
      p "Error: #{eot}"
  end
end

# Receive intern application
post "/a/?" do
  name = params["name"]
  email = params["email"]
  note = params["note"]
  skills = params["skills"]

  custom_fields = [{ :Key => "type", :Value => "ia" }]
  add_cm_subscriber email, name, custom_fields

  # Respond with 201 Created
  status 201
end

# Receive remote volunteer application
post "/rva/?" do
  name = params["name"]
  email = params["email"]
  note = params["note"]

  custom_fields = [{ :Key => "type", :Value => "rva" }]
  add_cm_subscriber email, name, custom_fields

  # Respond with 201 Created
  status 201
end
