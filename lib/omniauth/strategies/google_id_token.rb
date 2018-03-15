require 'omniauth'
require 'google-id-token'

module OmniAuth
  module Strategies
    class GoogleIdToken
      class ClaimInvalid < StandardError; end

      include OmniAuth::Strategy

      BASE_SCOPES = %w[profile email openid].freeze
      RESPONSE_TYPES = %w[token id_token].freeze

      option :cert, nil
      option :expiry, 3600 # 1 hour
      option :uid_claim, 'email'
      option :client_id, nil # Required for request_phase e.g. redirect to auth page
      option :aud_claim, nil
      option :azp_claim, nil
      option :required_claims, %w(name email)
      option :info_map, {"name" => "name", "email" => "email"}

      def request_phase
        redirect URI::HTTPS.build(host: 'accounts.google.com', path: '/o/oauth2/auth', query: URI.encode_www_form(authorize_params)).to_s.gsub(/\+/, '%20')
      end

      def authorize_params
        params = {}
        params[:scope] = BASE_SCOPES.join(' ')
        params[:access_type] = 'offline'
        params[:include_granted_scopes] = true
        params[:state] = SecureRandom.hex(24)
        session["omniauth.state"] = params[:state]
        params[:redirect_uri] = callback_url
        params[:response_type] = RESPONSE_TYPES.join(' ')
        params[:client_id] = options.client_id
        params
      end

      def decoded
        unless @decoded
          begin
            @decoded = validator.check(request.params['id_token'], options.aud_claim, options.azp_claim)
          rescue StandardError => e
            raise ClaimInvalid.new(e.message)
          end
        end

        (options.required_claims || []).each do |field|
          raise ClaimInvalid.new("Missing required '#{field}' claim.") if !@decoded.key?(field.to_s)
        end
        @decoded
      end

      def callback_phase
        super
      rescue ClaimInvalid => e
        fail! :claim_invalid, e
      end

      uid do
        decoded[options.uid_claim]
      end

      extra do
        {:raw_info => decoded}
      end

      info do
        options.info_map.inject({}) do |h,(k,v)|
          h[k.to_s] = decoded[v.to_s]
          h
        end
      end

      private

      def validator
        unless @validator
          validator_options = {expiry: options.expiry}
          validator_options.merge!({x509_cert: options.cert}) if options.cert
          @validator = ::GoogleIDToken::Validator.new(validator_options)
        end
        @validator
      end

      def uid_lookup
        @uid_lookup ||= options.uid_claim.new(request)
      end

    end

  end
end
