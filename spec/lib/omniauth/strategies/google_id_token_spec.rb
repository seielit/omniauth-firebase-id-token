require 'spec_helper'
require 'multi_json'
require 'jwt'

class TestLookup
  def initialize(request)
    @request = request
  end

  def uid(decoded)
    "foo"
  end
end

describe OmniAuth::Strategies::GoogleIdToken do
  let(:rsa_private){ OpenSSL::PKey::RSA.generate 512 }
  let(:rsa_public){ rsa_private.public_key }
  let(:cert) do
    cert = OpenSSL::X509::Certificate.new
    cert.public_key = rsa_public
    cert
  end
  let(:aud_claim){ 'test_audience_claim' }
  let(:azp_claim){ 'test_azp_claim' }
  let(:client_id){ 'test_client_id' }
  let(:response_json){ MultiJson.load(last_response.body) }
  let(:args){
    [nil,
     {
      cert: cert,
      algorithm: 'RS256',
      aud_claim: aud_claim,
      azp_claim: azp_claim,
      client_id: client_id
    }
  ]
  }

  let(:app){
    the_args = args
    Rack::Builder.new do |b|
      b.use Rack::Session::Cookie, secret: 'sekrit'
      b.use OmniAuth::Strategies::GoogleIdToken, *the_args
      b.run lambda{|env| [200, {}, [(env['omniauth.auth'] || {}).to_json]]}
    end
  }

  context 'request phase' do
    it 'should redirect to the configured login url' do
      get '/auth/googleidtoken'
      expect(last_response.status).to eq(302)
      expect(last_response.headers['Location'].gsub(/&state=[0-9a-z]*/, '')).to eq('https://accounts.google.com/o/oauth2/auth?scope=profile%20email%20openid&access_type=offline&include_granted_scopes=true&redirect_uri=http%3A%2F%2Fexample.org%2Fauth%2Fgoogleidtoken%2Fcallback&response_type=token%20id_token&client_id=test_client_id') # Removed state random field
    end
  end

  context 'callback phase' do
    it 'should decode the response' do
      encoded = JWT.encode({name: 'Bob', email: 'bob@example.com', 'iss': 'https://accounts.google.com', aud: aud_claim, azp: azp_claim}, rsa_private, 'RS256')
      get '/auth/googleidtoken/callback?jwt=' + encoded
      expect(response_json["info"]["email"]).to eq("bob@example.com")
    end

    it 'should not work without required fields' do
      encoded = JWT.encode({name: 'bob'}, 'imasecret')
      get '/auth/googleidtoken/callback?jwt=' + encoded
      expect(last_response.status).to eq(302)
    end

    it 'should assign the uid' do
      encoded = JWT.encode({name: 'Bob', email: 'bob@example.com', 'iss': 'https://accounts.google.com', aud: aud_claim, azp: azp_claim}, rsa_private, 'RS256')
      get '/auth/googleidtoken/callback?jwt=' + encoded
      expect(response_json["uid"]).to eq('bob@example.com')
    end
  end
end
