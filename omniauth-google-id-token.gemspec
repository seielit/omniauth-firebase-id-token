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

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "rack-test"

  spec.add_dependency "omniauth", "~> 1.1"
  spec.add_dependency "google-id-token", "~> 1.4"
end
