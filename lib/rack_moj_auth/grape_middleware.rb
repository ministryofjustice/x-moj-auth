module RackMojAuth
  class GrapeMiddleware < Grape::Middleware::Base

    def before
      verify_session_exists
    end

  private
    
    def verify_session_exists
      token = request.env[RackMojAuth::Resources::SECURE_TOKEN]
      if token.blank?
        you_shall_not_pass(403, 'missing session')
      end
    end

    def you_shall_not_pass(status, error)
      throw :error,
            message: error,
            status: status
    end
  end
end