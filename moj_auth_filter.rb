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
    @env = env

    status = 403
    headers = []
    body = []

    validate_secure_token
    filter_sensitive_headers

    unless @user.nil?
      add_userid_header
      add_user_role_header

      status, headers, body = @app.call(@env)
    end

    [status, headers, body]
  end

  private

  def add_userid_header
    @env[HEADER_user] = @user
  end

  def add_user_role_header
    if(@@user_roles)
      @env[HEADER_role] = @@user_roles
    end
  end

  def filter_sensitive_headers
    @env.delete(HEADER_token)
    @env.delete(HEADER_user)
    @env.delete(HEADER_role)
  end

  def validate_secure_token
    if @env[HEADER_token] == @@secure_token
      @user = @@user_id
    end
  end

end