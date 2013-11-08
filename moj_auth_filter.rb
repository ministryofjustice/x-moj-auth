HEADER_token = 'HTTP_X_SECURE_TOKEN'
HEADER_role = 'HTTP_X_USER_ROLES'
HEADER_user = 'HTTP_X_USER_ID'

class MojAuthFilter

  @@secure_token = '123456'
  @@user_id = 'joe.bloggs@example.com'
  @@user_roles = 'doge'

  def initialize( app )
    @app = app
  end

  def call( env )
    status = 403
    headers = []
    body = []

    user = validate_secure_token( env[HEADER_token] )
    env = filter_sensitive_headers(env)

    unless user.nil?
      env = add_userid_header( env, user )
      env = add_user_role_header( env )

      status, headers, body = @app.call(env)
    end

    [status, headers, body]
  end

  private

  def add_userid_header( env, user )
    env[HEADER_user] = user
    env
  end

  def add_user_role_header( env )
    if(@@user_roles)
      env[HEADER_role] = @@user_roles
    end
    env
  end

  def filter_sensitive_headers(env)
    env.delete(HEADER_token)
    env.delete(HEADER_user)
    env.delete(HEADER_role)
    env
  end

  def validate_secure_token( passed_token )
    if passed_token == @@secure_token
      return @@user_id
    else
      return nil
    end
  end

end