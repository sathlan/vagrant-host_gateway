# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant/host_gateway/version'

Gem::Specification.new do |gem|
  gem.name          = "vagrant-host_gateway"
  gem.version       = Vagrant::HostGateway::VERSION
  gem.authors       = ["sathlan"]
  gem.email         = ["chem+code@sathlan.org"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'pry-nav'
  gem.add_development_dependency 'debugger'
  gem.add_runtime_dependency('ipaddress')
  gem.add_runtime_dependency('vagrant', '~>1.0.6')

end
