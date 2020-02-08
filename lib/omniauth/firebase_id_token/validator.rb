# frozen_string_literal: true

# rubocop:disable Lint/MissingCopEnableDirective
# rubocop:disable Layout/AlignArguments
# rubocop:disable Style/NumericPredicate

require 'json'
require 'jwt'
require 'faraday'

module OmniAuth
  module FirebaseIdToken
    class ValidationError < StandardError; end
    class SignatureError < ValidationError; end
    class CertificateError < ValidationError; end

    # Adapted from [google/google-id-token GoogleIDToken::Validator](https://github.com/google/google-id-token/blob/master/lib/google-id-token.rb)
    class Validator
      CERTS_URL = 'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com'
      attr_accessor :certificates

      def initialize
        self.certificates = []
      end

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
      def check(token, aud, cid = nil)
        try ||= 0
        refresh_certs!

        payload = do_check token, aud, cid

        raise SignatureError, 'Signature is invalid!' unless payload

        payload
      rescue JWT::ExpiredSignature
        raise if try > 0

        try += 1

        logger.warn '  * certificates are expired, fetching again…'
        refresh_certs! expired: true

        retry
      end

      def refresh_certs!(expired: false)
        return unless expired || certificates.blank?

        logger.info " ** retrieving certificates from #{CERTS_URL}…"
        res = Faraday.get CERTS_URL
        err = 'Unable to retrieve Google public keys'

        raise CertificateError, err unless res.status == 200

        data = JSON.parse res.body
        certs = data.map { |key, cert|
          [
            key,
            OpenSSL::X509::Certificate.new(cert)
          ]
        }
        self.certificates = Hash[certs]

        logger.info "  * certificates retrieved: #{certificates.keys}"
      rescue Faraday::ConnectionFailed
        raise CertificateError,
          'Unable to connect to to Google to retrieve public keys'
      rescue JSON::ParserError
        raise CertificateError,
          "Failed to parse Google certificates: #{res.body}"
      end

      private

      def do_check(token, aud, cid)
        _, headers = JWT.decode token,
          nil,
          false,
          algorithm: 'RS256'
        keyid = headers['kid']
        key = certificates[keyid]

        byebug
        cert_error = "No certificate #{keyid} among #{certificates.keys}"
        raise CertificateError, cert_error if key.blank?

        payload, = JWT.decode token,
          key,
          true,
          algorithm: 'RS256'

        byebug
        logger.debug token
        logger.debug payload

        payload
        # # rescue JWT::ExpiredSignature
        # rescue JWT::DecodeError
        #   byebug
        #   2 + 2
      end

      def get(url)
        uri = URI(url)
        get = Net::HTTP::Get.new uri.request_uri
        http = Net::HTTP.new uri.host, uri.port
        http.use_ssl = true

        http.request get
      end

      def logger
        OmniAuth.logger
      end
    end
  end
end
