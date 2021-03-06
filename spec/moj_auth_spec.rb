require 'json'
require 'rack'
require 'rack/test'
require 'webmock/rspec'

require File.join(File.dirname(__FILE__), '..', 'lib', 'rack_moj_auth')

describe 'RackMojAuth::Middleware' do
  include Rack::Test::Methods

  before :all do
    backend = Proc.new { |env| code = env.has_key?('X-USER-ID') ? 202 : 500; [ code, {}, [] ] }
    builder = Rack::Builder.new

    builder.use RackMojAuth::ProxyMiddleware
    builder.run backend
    @app = builder.to_app

    @backend = Rack::MockRequest.new(@app)

    @auth_service_url = 'http://auth.service'
  end

  it 'proxies post requests to /auth/user to the auth service' do
    stub_request(:post, "#{@auth_service_url}/users").to_return(status: 201, body: [{email: "joe.bloggs@example.com", authentication_token: "Pm2tbZfcwfD7B1jK_wzo"}.to_json], headers: {})
    response = @backend.post('/auth/users', {'user' => { 'email' => 'joe.bloggs@example.com', 'password' => 's3kr!tpa55'}})

    expect(response.status).to eql 201
    expect(JSON.parse(response.body)['authentication_token']).to eql "Pm2tbZfcwfD7B1jK_wzo"
  end


  it 'proxies failed requests to /auth/user' do
    stub_request(:post, "#{@auth_service_url}/users").to_return(status: 422, body: [{errors: {email: ["is invalid"], password: ["can't be blank"]}}.to_json], headers: {})
    response = @backend.post('/auth/users', {'user' => { 'email' => 'joe.bloggs@example.com', 'password' => 's3kr!tpa55'}})

    expect(response.status).to eql 422
    expect(JSON.parse(response.body)['errors']['email']).to eql ["is invalid"]
  end


  it 'proxies login requests /auth/users/sign_in' do
    stub_request(:post, "#{@auth_service_url}/users/sign_in").to_return(status: 201, body: [{email: "joe.bloggs@example.com", authentication_token: "Pm2tbZfcwfD7B1jK_wzo"}.to_json], headers: {})
    response = @backend.post('/auth/users/sign_in', {'user' => { 'email' => 'joe.bloggs@example.com', 'password' => 's3kr!tpa55'}})

    expect(response.status).to eql 201
    expect(JSON.parse(response.body)['authentication_token']).to eql "Pm2tbZfcwfD7B1jK_wzo"
  end


  it 'proxies get requests to verify session tokens' do
    stub_request(:get, "#{@auth_service_url}/users/Pm2tbZfcwfD7B1jK_wzo").to_return(status: 200, body: [], headers: {X_USER_ID: 'joe.bloggs@example.com'})
    response = @backend.get('/auth/users/Pm2tbZfcwfD7B1jK_wzo')

    expect(response.status).to eql 200
    expect(response.headers[RackMojAuth::Resources::USER_ID]).to eql "joe.bloggs@example.com"
  end

  it 'proxies get requests to sign out' do
    stub_request(:delete, "#{@auth_service_url}/sessions/Pm2tbZfcwfD7B1jK_wzo").to_return(status: 204, body: nil)
    response = @backend.delete('/auth/sessions/Pm2tbZfcwfD7B1jK_wzo')

    expect(response.status).to eql 204
  end

  it 'it bounces requests that have no HTTP_SECURE_TOKEN header' do
    response = @backend.post('/any_url')

    expect(response.status).to eql 403
    expect(response.body).to be_empty
  end

  it 'it bounces requests that have an invalid HTTP_SECURE_TOKEN header' do
    stub_request(:get, "#{@auth_service_url}/users/invalid")
      .to_return(status: 401, body: [], headers: {})
    response = @backend.post('/any_url', {'HTTP_SECURE_TOKEN' => 'invalid'})

    expect(response.status).to eql 403
    expect(response.body).to be_empty
  end

  it 'it passes requests with a valid HTTP_SECURE_TOKEN header' do
    stub_request(:get, "#{@auth_service_url}/users/Pm2tbZfcwfD7B1jK_wzo")
      .to_return(status: 200, body: [], headers: {X_USER_ID: 'joe.bloggs@example.com'})
    response = @backend.post('/any_url', {'HTTP_SECURE_TOKEN' => 'Pm2tbZfcwfD7B1jK_wzo'})

    expect(response.status).to eql 202
  end

end