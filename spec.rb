require 'httparty'
require 'json'

class Mojauth
  include HTTParty
  base_uri 'http://localhost:9292'
end

describe 'moj_auth Middleware' do

  context 'Unauthenticated user' do

    before :all do
      @good_creds = {body: {username: 'joe.bloggs@example.com', password: 's3kr!t'} }
      @bad_creds = {body: {username: 'bad login'} }
    end

    describe '/register' do
      describe 'success' do
        it 'returns 201 status code' do
          resp = Mojauth.post('/register', @good_creds)
          resp.code.should eq 201
        end
      end

      describe 'failure' do
        it 'returns 400 status code' do
          resp = Mojauth.post('/register', @bad_creds)
          resp.code.should eq 400
        end
      end
    end


    describe '/login' do
      describe 'success' do
        it 'returns 200 status code' do
          resp = Mojauth.post('/login', @good_creds)
          resp.code.should eq 200
        end

        it 'returns a secure token ' do
          resp = Mojauth.post('/login', @good_creds)
          payload = JSON.parse(resp.body)
          payload['token'].should eq '123456'
        end
      end

      describe 'failure' do
        it 'returns 403 status code' do
          resp = Mojauth.post('/login', @bad_creds)
          resp.code.should eq 403
        end

        it 'doesn\'t return a secure token' do
          resp = Mojauth.post('/login', @bad_creds)
          payload = JSON.parse(resp.body)
          payload.should_not include 'token'
        end
      end
    end

    describe '/logout' do
      it 'returns 403 status code' do
        resp = Mojauth.post('/logout')
        resp.code.should eq 403
      end
      it 'returns no data' do
        resp = Mojauth.post('/logout')
        resp.body.should eq ''
      end
    end

    describe '/change_password' do
      it 'returns 403 status code' do
        resp = Mojauth.post('/logout')
        resp.code.should eq 403
      end 
      it 'returns no data' do
        resp = Mojauth.post('/logout')
        resp.body.should eq ''
      end 
    end

    describe 'missing secure-token header' do
      it 'returns 403 status code' do
        resp = Mojauth.get('/valid_route_on_api')
        resp.code.should eq 403
      end

      it 'returns no data' do
        resp = Mojauth.get('/valid_route_on_api')
        resp.body.should eq ''
      end
    end

    describe 'invalid secure-token header' do
      it 'returns 403 status code' do
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

    describe 'all other urls, with valid x-secure-token header' do
      it 'status code passed through from API' do
        resp = Mojauth.get('/valid_route_on_api', :headers => @valid_secure_token_header)
        resp.code.should eq 418
      end

      it 'response body passed through from API' do
        resp = Mojauth.get('/valid_route_on_api', :headers => @valid_secure_token_header)
        resp.body.should include('joe.bloggs@example.com')
      end

      it 'response headers passed through from API' do
        resp = Mojauth.get('/valid_route_on_api', :headers => @valid_secure_token_header)
        resp.headers['Content-Type'].should eq 'custom/special'
      end      
    end

    describe 'roles enrichment' do
      it 'adds API-side x-user-id header' do
        resp = Mojauth.get('/valid_route_on_api', :headers => @valid_secure_token_header)
        resp.body.should include('joe.bloggs@example.com')
      end

      it 'adds API-side x-user-role header' do
        resp = Mojauth.get('/valid_route_on_api', :headers => @valid_secure_token_header)
        resp.body.should include('doge')
      end      

      it 'filters client-side x-user-id header' do
        resp = Mojauth.get('/valid_route_on_api', :headers => {'x-user-id' => 'auth_bypass'}.merge(@valid_secure_token_header))
        resp.body.should_not include('auth_bypass')
      end

      it 'filters client-side x-user-role header' do
        resp = Mojauth.get('/valid_route_on_api', :headers => {'x-user-role' => 'auth_bypass'}.merge(@valid_secure_token_header))
        resp.body.should_not include('auth_bypass')
      end
    end
  end

end