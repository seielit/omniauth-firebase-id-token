# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth/google_id_token/version'

Gem::Specification.new do |spec|
  spec.name          = "omniauth-google-id-token"
  spec.version       = OmniAuth::GoogleIdToken::VERSION
  spec.authors       = ["Joshua Morris"]
  spec.email         = ["josh@masteryconnect.com"]
  spec.description   = %q{An OmniAuth strategy to validate Google id tokens.}
  spec.summary       = %q{An OmniAuth strategy to validate Google id tokens.}
  spec.homepage      = "http://github.com/MasteryConnect/omniauth-google-id-token"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rspec", "~> 3.7"
  spec.add_development_dependency "guard", "~> 2.14"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "rack-test", "~> 0.8"

  spec.add_runtime_dependency "omniauth", "~> 1.1"
  spec.add_runtime_dependency "google-id-token", "~> 1.4"
end
