# frozen_string_literal: true

require_relative 'lib/faraday/excon/version'

Gem::Specification.new do |spec|
  spec.name = 'faraday-excon'
  spec.version = Faraday::Excon::VERSION
  spec.authors = ['@iMacTia']
  spec.email = ['giuffrida.mattia@gmail.com']

  spec.summary = 'Faraday adapter for Excon'
  spec.description = 'Faraday adapter for Excon'
  spec.homepage = 'https://github.com/lostisland/faraday-excon'
  spec.license = 'MIT'

  spec.required_ruby_version = Gem::Requirement.new('>= 2.4.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/lostisland/faraday-excon'
  spec.metadata['changelog_uri'] = 'https://github.com/lostisland/faraday-excon'

  spec.files = Dir.glob('lib/**/*') + %w[README.md LICENSE.md]
  spec.require_paths = ['lib']

  # TODO: make this a normal dependency when releasing v2.0
  spec.add_development_dependency 'excon', '>= 0.27.4'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'faraday', '~> 1.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.19.0'

  spec.add_development_dependency 'multipart-parser', '~> 0.1.1'
  spec.add_development_dependency 'webmock', '~> 3.4'

  spec.add_development_dependency 'rubocop', '~> 0.91.1'
  spec.add_development_dependency 'rubocop-packaging', '~> 0.5'
  spec.add_development_dependency 'rubocop-performance', '~> 1.0'
end
