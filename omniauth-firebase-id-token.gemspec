# frozen_string_literal: true

# rubocop:disable Lint/MissingCopEnableDirective
# rubocop:disable Layout/ExtraSpacing
# rubocop:disable Layout/SpaceAroundOperators
# rubocop:disable Style/UnneededPercentQ

lib = File.expand_path('../lib', __FILE__) # rubocop:disable Style/ExpandPathArguments
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth/firebase_id_token/version'

Gem::Specification.new do |spec|
  spec.name          = 'omniauth-firebase_id_token'
  spec.version       = OmniAuth::FirebaseIdToken::VERSION
  spec.authors       = ['Ignacio Carrera', 'Joshua Morris']
  spec.email         = ['icarrera@seiel.it', 'josh@masteryconnect.com']
  spec.description   = %q(
    An OmniAuth strategy to validate Google Firebase Authentication id tokens.
  ).strip
  spec.summary       = %q(
    An OmniAuth strategy to validate Google Firebase Authentication id tokens.
  ).strip
  spec.homepage      = 'https://github.com/seielit/omniauth-firebase-id-token'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0.2'
  spec.add_development_dependency 'guard', '~> 2.14'
  spec.add_development_dependency 'guard-rspec', '~> 4.7'
  spec.add_development_dependency 'rack-test', '~> 0.8'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.7'

  spec.add_runtime_dependency 'faraday', '>= 1'
  spec.add_runtime_dependency 'jwt', '~> 2'
  spec.add_runtime_dependency 'omniauth', '~> 1'
end
