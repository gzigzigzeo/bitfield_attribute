# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bitfield_attribute/version'

Gem::Specification.new do |spec|
  spec.name          = "bitfield_attribute"
  spec.version       = BitfieldAttribute::VERSION
  spec.authors       = ["Viktor Sokolov"]
  spec.email         = ["gzigzigzeo@evilmartians.com"]
  spec.summary       = %q{Bitfield value object for ActiveModel}
  spec.description   = %q{Bitfield value object for ActiveModel. No hidden definitions. No callbacks. Magicless.}
  spec.homepage      = "https://github.com/gzigzigzeo/bitfield_attribute"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"

  spec.add_dependency "activemodel", ">= 4.0", "< 7"
  spec.add_dependency "activerecord", ">= 4.0", "< 7"
end
