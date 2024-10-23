require_relative "lib/highs/version"

Gem::Specification.new do |spec|
  spec.name          = "highs"
  spec.version       = Highs::VERSION
  spec.summary       = "Linear optimization for Ruby"
  spec.homepage      = "https://github.com/ankane/highs-ruby"
  spec.license       = "MIT"

  spec.author        = "Andrew Kane"
  spec.email         = "andrew@ankane.org"

  spec.files         = Dir["*.{md,txt}", "{lib,vendor}/**/*"]
  spec.require_path  = "lib"

  spec.required_ruby_version = ">= 3.1"

  spec.add_dependency "fiddle"
end
