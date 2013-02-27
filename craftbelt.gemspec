# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'craftbelt/version'

Gem::Specification.new do |gem|
  gem.name          = 'craftbelt'
  gem.version       = Craftbelt::VERSION
  gem.authors       = ["Dave Newman"]
  gem.email         = ["dave@minefold.com"]
  gem.description   = %q{Useful Minecraft utilities}
  gem.summary       = %q{Test Minefold funpacks}
  gem.homepage      = "https://minefold.com"

  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'nbtfile'
  gem.add_development_dependency 'rspec'

  gem.files = %w(
    Gemfile
    README.md
    craftbelt.gemspec
  ) + Dir['{lib,spec}/**/*']
end
