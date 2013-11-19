# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack_moj_auth/version'

Gem::Specification.new do |gem|
  gem.name          = "rack_moj_auth"
  gem.version       = RackMojAuth::Middleware::VERSION
  gem.authors       = ["Tom Gladhill"]
  gem.email         = ["whoojemaflip@gmail.com"]
  gem.description   = %q{Simple Rack Middleware implementation of distributed Moj Auth pattern}
  gem.summary       = %q{Include in your development Rack project to integrate with Moj Auth service.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'rack', ">= 1.5.0"
  gem.add_runtime_dependency 'httparty',   ">= 0.12.0"

  gem.add_development_dependency 'rspec', ">= 2.14.0"
  gem.add_development_dependency 'rack-test', ">= 0.6.2"
  gem.add_development_dependency 'webmock', ">= 1.16.0"
  gem.add_development_dependency 'excon', ">=0.27.5"
end
