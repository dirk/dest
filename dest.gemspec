# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dest/version'

Gem::Specification.new do |spec|
  spec.name          = "destination"
  spec.version       = Dest::VERSION
  spec.authors       = ["Dirk Gadsden"]
  spec.email         = ["dirk@dirk.to"]
  spec.summary       = "Free your code from Xcode"
  spec.description   = "Tool for building Objective-C code without the use of Xcode"
  spec.homepage      = "https://github.com/dirk/dest"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rake"
  spec.add_dependency 'colorize', '~> 0.7'

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rspec", '~> 3.0', '>= 3.0.0'
  spec.add_development_dependency "rspec-expectations", '~> 3.0', '>= 3.0.0'
end
