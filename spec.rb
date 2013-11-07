require 'httparty'
require 'json'

class Mojauth
  include HTTParty
  base_uri 'http://localhost:9292'
end

describe 'moj_auth Middleware' do

  context 'Unauthenticated user' do

    before :all do
      @good_creds = {body: {username: 'joe',password: 'bloggs'} }
      @bad_creds = {body: {username: 'bad login'} }
    end

    describe '/register' do
      it 'returns 201 status code on success' do
        resp = Mojauth.post('/register', @good_creds)
        resp.code.should eq 201
      end

      it 'returns 400 status code on failure' do
        resp = Mojauth.post('/register', @bad_creds)
        resp.code.should eq 400
      end
    end


    describe '/login' do
      it 'returns a secure token' do
        resp = Mojauth.post('/login', @good_creds)
        payload = JSON.parse(resp.body)
        payload['token'].should eq '123456'
      end

      it 'rejects bad credentials' do
        resp = Mojauth.post('/login', @bad_creds)
        resp.code.should eq 403
      end
    end

    describe '/logout' do
      it 'returns 403 status code' do
        resp = Mojauth.post('/logout')
        resp.code.should eq 403
      end
    end

    describe '/change_password' do
      it 'returns 403 status code' do
        resp = Mojauth.post('/logout')
        resp.code.should eq 403
      end 
    end

    describe 'missing secure-token header' do
      it 'returns 403' do
        resp = Mojauth.get('/valid_route_on_api')
        resp.code.should eq 403
      end

      it 'returns no data' do
        resp = Mojauth.get('/valid_route_on_api')
        resp.body.should eq ''
      end
    end

    describe 'invalid secure-token header' do
      it 'returns 403' do
        resp = Mojauth.get('/valid_route_on_api', :headers => {'x-secure-token' => 'bad-token'})
        resp.code.should eq 403
      end

      it 'returns no data' do
        resp = Mojauth.get('/valid_route_on_api', :headers => {'x-secure-token' => 'bad-token'})
        resp.body.should eq ''
      end
    end

  end

  context 'Authenticated user' do
    before :each do
      @valid_secure_token_header = {'x-secure-token' => '123456'}
      @invalid_secure_token_header = {'x-secure-token' => 'bad-token'}
    end

    describe '/logout' do
      it 'returns 200 status code' do
        resp = Mojauth.post('/logout', :headers => @valid_secure_token_header)
        resp.code.should eq 200
      end
    end

    describe '/change_password' do
      it 'returns 200 status code' do
        resp = Mojauth.post('/logout', :headers => @valid_secure_token_header)
        resp.code.should eq 200
      end 
    end

    describe 'successfully hitting the API' do
      it 'passes through the status code' do
        resp = Mojauth.get('/valid_route_on_api', :headers => @valid_secure_token_header)
        resp.code.should eq 418
      end

      it 'passes through the response body' do
        resp = Mojauth.get('/valid_route_on_api', :headers => @valid_secure_token_header)
        resp.body.should eq 'API response'
      end

      it 'passes through the response headers' do
        resp = Mojauth.get('/valid_route_on_api', :headers => @valid_secure_token_header)
        resp.headers['Content-Type'].should eq 'custom/special'
      end      
    end
  end

end