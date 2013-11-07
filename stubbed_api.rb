# my_app.rb
class StubbedApi
  def call(env)
    [418, {"Content-Type" => "custom/special"}, ["API response"]] 
  end
end