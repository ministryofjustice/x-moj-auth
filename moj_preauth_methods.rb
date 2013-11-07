require 'rack'
require 'sinatra/base'
require 'json'

class MojPreAuthMethods < Sinatra::Base

  @@username = 'joe'
  @@password = 'bloggs'
  @@secure_token = '123456'

  post '/login' do
    if valid_login_credentials( params )
      status 200
      content_type "text/json"
      body ({:token => @@secure_token}.to_json)
    else
      status 403
      content_type "text/json"
      body ({:error => 'bad login'}.to_json)
    end
  end

  post '/register' do
    if valid_registration_details( params )
      status 201
    else
      status 400
    end
  end

  private

  def valid_login_credentials( params )
    (params[:username] == @@username && params[:password] == @@password)
  end

  def valid_registration_details( params )
    ( params.has_key?('username') && params.has_key?('password') )
  end
end   