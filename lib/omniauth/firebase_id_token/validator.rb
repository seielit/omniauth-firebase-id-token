# frozen_string_literal: true

# rubocop:disable Lint/MissingCopEnableDirective
# rubocop:disable Layout/MultilineOperationIndentation

require 'json'
require 'faraday'

module OmniAuth
  module FirebaseIdToken
    class ValidationError < StandardError; end
    class SignatureError < ValidationError; end
    class CertificateError < ValidationError; end

    # Adapted from [google/google-id-token GoogleIDToken::Validator](https://github.com/google/google-id-token/blob/master/lib/google-id-token.rb)
    class Validator
      VERIFY_URL = 'https://oauth2.googleapis.com/tokeninfo?id_token=%<token>s'

      ##
      # If valid, returns a hash with the token's claims.
      #
      # If something fails, raises an error
      #
      # @param [String] token
      #   The string form of the token
      # @param [String] aud
      #   The required audience value; must match the token's field
      #
      # @return [Hash] The decoded ID token
      def check!(token, aud, azp = nil)
        res = Faraday.get token_url(token)

        data = JSON.parse res.body
        valid = aud == data['aud'] &&
          azp.blank? || (azp == data['azp'])

        error = "Signature is invalid! #{res.status} #{res.body}"
        raise SignatureError, error unless res.status == 200 && valid

        data
      end

      def token_url(token)
        VERIFY_URL % {
          token: token
        }
      end
    end
  end
end
