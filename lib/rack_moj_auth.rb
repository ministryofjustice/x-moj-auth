require 'rack'
require 'httparty'

require 'rack_moj_auth/railtie' if defined?(Rails)

module RackMojAuth
  class Middleware

    @@token_header = 'X-SECURE-TOKEN'
    @@role_header = 'X-USER-ROLES'
    @@user_header = 'X-USER-ID'

    def initialize( app )
      @auth_service_url = ENV['auth_service_url'] || 'http://auth.service'
      @app = app
    end

    def call( env )
      @env = env
      @request = Rack::Request.new(@env)
      @response = nil

      auth_proxy if /^\/auth\//.match @request.path_info
      return @response.finish if @response

      return [403, {}, []] unless is_logged_in

      filter_sensitive_headers  # remove user id headers from request

      @env[@@user_header] = get_user[:id] # enrich headers with user object

      status, headers, body = @app.call(@env) # pass request through to backend
      [status, headers, body]
    end

  private

    def auth_proxy
      r = HTTParty.get("http://auth.service") # etc...
      @response = Rack::Response.new(r.body, r.code, r.headers)
    end

    def filter_sensitive_headers
      @env.delete(@@token_header)
      @env.delete(@@role_header)
      @env.delete(@@user_header)
    end

    def get_user
      {id: @user['id']}
    end

    def is_logged_in
      return false unless @env.has_key? @@token_header

      token = @env[@@token_header]
      url = "#{@auth_service_url}/sessioncheck?token=#{token}"
      auth = HTTParty.get(url)
      @user = JSON.parse(auth.body || '{}')
      return (auth.code == 200)
    end
  end
end