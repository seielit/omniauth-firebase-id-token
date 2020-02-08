# frozen_string_literal: true

# rubocop:disable Lint/MissingCopEnableDirective
# rubocop:disable Layout/AlignArguments
# rubocop:disable Style/Documentation
# rubocop:disable Style/EachWithObject
# rubocop:disable Style/RaiseArgs

require 'omniauth'
require 'omniauth/firebase_id_token/validator'

module OmniAuth
  module Strategies
    class FirebaseIdToken
      class ClaimInvalid < StandardError; end

      include OmniAuth::Strategy

      BASE_SCOPES = %w[profile email openid].freeze
      RESPONSE_TYPES = %w[token id_token].freeze

      option :name, 'firebase_id_token'
      option :cert, nil
      option :expiry, 3600 # 1 hour
      option :uid_claim, 'email'
      option :client_id, nil # Req'd for request_phase eg. redirect to auth page
      option :aud_claim, nil
      option :azp_claim, nil
      option :required_claims,
        %w[email]
      option :info_map,
        'name' => 'name',
        'email' => 'email'

      def request_phase
        redirect URI::HTTPS.build(
          host: 'accounts.google.com',
          path: '/o/oauth2/auth',
          query: URI.encode_www_form(authorize_params)
        ).to_s.gsub(/\+/, '%20')
      end

      def authorize_params
        params = {}
        params[:scope] = BASE_SCOPES.join(' ')
        params[:access_type] = 'offline'
        params[:include_granted_scopes] = true
        params[:state] = SecureRandom.hex(24)
        session['omniauth.state'] = params[:state]
        params[:redirect_uri] = callback_url
        params[:response_type] = RESPONSE_TYPES.join(' ')
        params[:client_id] = options.client_id
        params
      end

      def decoded
        @decoded ||= decode_claims

        assert_claims! options.required_claims,
          @decoded

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
        { raw_info: decoded }
      end

      info do
        options.info_map.inject({}) do |h, (k, v)|
          h[k.to_s] = decoded[v.to_s]
          h
        end
      end

      private

      def validator
        @validator ||= OmniAuth::FirebaseIdToken::Validator.new
      end

      def uid_lookup
        @uid_lookup ||= options.uid_claim.new(request)
      end

      def decode_claims
        token = request.params['id_token']
        audc = options.aud_claim
        azpc = options.azp_claim

        @decoded = validator.check! token,
          audc, azpc
      rescue StandardError => e
        logger.error " ** @slack Invalid token: #{e}"
        raise ClaimInvalid.new(e.message)
      end

      def assert_claims!(required, claims)
        required.each do |claim|
          next if claims.key?(claim.to_s)

          raise ClaimInvalid.new("Missing required '#{claim}' claim.")
        end
      end

      def logger
        OmniAuth.logger
      end
    end
  end
end
