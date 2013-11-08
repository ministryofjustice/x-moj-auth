class StubbedApi
  def call(env)
    body = "API response\n"
    body << get_user_greeting( env )
    body << get_user_roles( env )

    [418, {"Content-Type" => "custom/special"}, [body]] 
  end

  def get_user_greeting( env )
    return_value = ''
    if env['HTTP_X_USER_ID']
      email_addy = env['HTTP_X_USER_ID']
      return_value << "Hello #{email_addy}\n"
    end
    return_value
  end

  def get_user_roles( env )
    return_value = ''
    if env['HTTP_X_USER_ROLES']
      return_value << "roles: #{env['HTTP_X_USER_ROLES']}\n"
    end
    return_value
  end
end