# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pluck_each/version'

Gem::Specification.new do |spec|
  spec.name          = "pluck_each"
  spec.version       = PluckEach::VERSION
  spec.authors       = ["Brandon Dewitt"]
  spec.email         = ["brandonsdewitt@gmail.com"]
  spec.summary       = %q{ pluck_each and plucK_in_batches ... should behave like find_each and find_in_batches }
  spec.description   = %q{ pluck_each and plucK_in_batches ... should behave like find_each and find_in_batches }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", "> 3.2.0"
  spec.add_dependency "activesupport", "> 3.0.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", ">= 12.3.3"
end
