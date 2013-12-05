require 'rack'
require 'httparty'

module RackMojAuth
  class ProxyMiddleware

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

      @env[RackMojAuth::Resources::USER_ID] = @user_id # enrich headers with user object

      status, headers, body = @app.call(@env) # pass request through to backend
      [status, headers, body]
    end

  private

    def auth_proxy
      url = @auth_service_url + '/' + @request.path_info.gsub(/^\/auth\//, '')
      method = @request.request_method.downcase
      data = @request.params

      if method.to_s[/post/i]
        r = HTTParty.post(url, body: data)
      else
        r = HTTParty.send(method, url, data)
      end

      @response = Rack::Response.new(r.body || [], r.code, r.headers)
    end

    def filter_sensitive_headers
      @env.delete(RackMojAuth::Resources::SECURE_TOKEN)
      @env.delete(RackMojAuth::Resources::ROLES)
      @env.delete(RackMojAuth::Resources::USER_ID)
    end

    def is_logged_in
      return false unless @env.has_key? RackMojAuth::Resources::SECURE_TOKEN

      token = @env[RackMojAuth::Resources::SECURE_TOKEN]
      url = "#{@auth_service_url}/users/#{token}"
      resp = HTTParty.get(url)
      @user_id = resp.headers[RackMojAuth::Resources::USER_ID]
      return (resp.code == 200)
    end
  end
end