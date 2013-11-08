require 'rack'
require 'sinatra/base'
require 'json'

class MojPreAuthMethods < Sinatra::Base

  @@username = 'joe.bloggs@example.com'
  @@password = 's3kr!t'
  @@secure_token = '123456'

  post '/login' do
    content_type "text/json"
    if valid_login_credentials( params )
      status 200
      body ({:token => @@secure_token}.to_json)
    else
      error 403, {:error => 'bad login'}.to_json
    end
  end

  post '/register' do
    if valid_registration_details( params )
      status 201
    else
      error 400
    end
  end

  private

  def valid_login_credentials( params )
    # puts params[:username]
    # puts @@username
    # puts params[:password]
    # puts @@password
    (params[:username] == @@username && params[:password] == @@password)
  end

  def valid_registration_details( params )
    ( params.has_key?('username') && params.has_key?('password') )
  end
end   