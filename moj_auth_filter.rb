class MojAuthFilter

  @@secure_token = '123456'
  @@user_id = 'joe.bloggs@example.com'

  def initialize( app )
    @app = app
  end

  def call( env )
    status = 403
    headers = []
    body = []

    user = validate_secure_token( env['HTTP_X_SECURE_TOKEN'] )

    unless user.nil?
      status, headers, body = @app.call(env)
      headers['X-MOJ-USERID'] = user
    end
    
    [status, headers, body]
  end

  private

  def validate_secure_token( passed_token )
    if passed_token == @@secure_token
      return @@user_id
    else
      return nil
    end
  end

end