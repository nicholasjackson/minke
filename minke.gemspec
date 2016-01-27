# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'minke/version'

Gem::Specification.new do |spec|
  spec.name          = "minke"
  spec.version       = Minke::VERSION
  spec.authors       = ["Nic Jackson"]
  spec.email         = ["jackson.nic@gmail.com"]

  spec.summary       = "Minke is a suite of rake tasks for building and testing microservices with Docker.  Currently supporting Google Go, Node.js services are coming soon."
  spec.homepage      = "https://github.com/nicholasjackson/minke"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rspec"

  spec.add_runtime_dependency 'cucumber'
  spec.add_runtime_dependency 'rake', "~> 10.0"
  spec.add_runtime_dependency 'docker-api'
  spec.add_runtime_dependency 'rest-client', '~> 1.8'
  spec.add_runtime_dependency 'consul_loader', '~> 1.0'
end
