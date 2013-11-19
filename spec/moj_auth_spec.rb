require 'json'
require 'rack'
require 'rack/test'
require 'webmock/rspec'

require File.join(File.dirname(__FILE__), '..', 'lib', 'rack_moj_auth')

describe 'Rack::MojAuth' do
  include Rack::Test::Methods

  before :all do
    backend = Proc.new { |env| code = env.has_key?('X-USER-ID') ? 200 : 500; [code, {'Content-Type' => "text/html"}, ['backend-application']] }
    builder = Rack::Builder.new

    builder.use Rack::MojAuth
    builder.run backend
    @app = builder.to_app

    @backend = Rack::MockRequest.new(@app)

    @auth_service_url = 'http://auth.service'
  end

  it 'proxies all requests to /auth/ to the auth service' do
    stub_request(:get, @auth_service_url).to_return(status: 418, body: 'authentication-api', headers: {})
    response = @backend.post('/auth/whatever')

    expect(response.status).to eql 418
    expect(response.body).to eql 'authentication-api'
  end

  it 'it bounces requests that have no X-SECURE-TOKEN header' do
    response = @backend.post('/any_url')

    expect(response.status).to eql 403
    expect(response.body).to be_empty
  end

  it 'it bounces requests that have an invalid X-SECURE-TOKEN header' do
    stub_request(:get, "#{@auth_service_url}/sessioncheck")
      .with(query: {"token" => "test"})
      .to_return(status: 403, body: '', headers: {})
    response = @backend.post('/any_url', {'X-SECURE-TOKEN' => 'test'})

    expect(response.status).to eql 403
    expect(response.body).to be_empty
  end

  it 'it passes requests with a valid X-SECURE-TOKEN header' do
    stub_request(:get, "#{@auth_service_url}/sessioncheck?token=Test")
      .with(query: {"token" => "test"})
      .to_return(status: 200, body: {id: 'user-id'}.to_json, headers: {})
    response = @backend.post('/any_url', {'X-SECURE-TOKEN' => 'test'})

    expect(response.status).to eql 200
    expect(response.body).to eql 'backend-application'
  end

end