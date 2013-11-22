require 'rack'

module RackMojAuth
  class PreventAnonymousAccess
    
    def initialize(app)
      @app = app
    end

    def call(env)
      return [403, {}, []] unless env.has_key? RackMojAuth::Resources::USER_ID
      @app.call(env)
    end
  end
end