# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'slather/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'danger-slather'
  spec.version       = Slather::VERSION
  spec.authors       = ['Bruno Mazzo']
  spec.email         = ['mazzo.bruno@gmail.com']
  spec.description   = %q{Danger plugin to Slather code coverage framework}
  spec.summary       = %q{A Danger plugin that show code coverage of the project and by file.
                          Add warnings or fail the build if a minimum coverage
                          are not achieved. It uses Slather Framework for calculate
                          coverage, so it's required to configurate the slather
                          object before using it.}
  spec.homepage      = 'https://github.com/BrunoMazzo/danger-slather'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/).reject do |file|
    file.start_with?('doc/')
  end
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'danger-plugin-api', '~> 1.0'
  spec.add_runtime_dependency 'slather', '~> 2.3'

  # General ruby development
  spec.add_development_dependency 'bundler', '>= 2.2.33'
  spec.add_development_dependency 'rake', '>= 12.3.3'

  # Testing support
  spec.add_development_dependency 'mocha', '~> 1.2' # Need to redo all tests
  spec.add_development_dependency 'rspec', '~> 3.4'

  # Linting code and docs
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.add_development_dependency 'yard', '>= 0.9.20'

  # Makes testing easy via `bundle exec guard`
  spec.add_development_dependency 'guard', '~> 2.14'
  spec.add_development_dependency 'guard-rspec', '~> 4.7'

  # If you want to work on older builds of ruby
  spec.add_development_dependency 'listen', '3.0.7'

  # This gives you the chance to run a REPL inside your tests
  # via:
  #
  #    require 'pry'
  #    binding.pry
  #
  # This will stop test execution and let you inspect the results
  spec.add_development_dependency 'pry', '~> 0.9'
end
