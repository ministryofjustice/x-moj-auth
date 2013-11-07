class StubbedApi
  def call(env)
    body = "API response"
    if env['HTTP_X_MOJ_USERID']
      email_addy = env['HTTP_X_MOJ_USERID']
      body = "Hello #{email_addy}"
    end

    [418, {"Content-Type" => "custom/special"}, [body]] 
  end
end