require 'sinatra/base'

class MojPostAuthMethods < Sinatra::Base

  post '/logout' do
    status 200
  end

  post 'change_password' do
    status 200
  end

end   