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

  spec.required_ruby_version = Gem::Requirement.new('>= 2.6.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['source_code_uri'] = 'https://github.com/lostisland/faraday-excon'
  spec.metadata['changelog_uri'] = "https://github.com/lostisland/faraday-excon/releases/tag/v#{spec.version}"

  spec.files = Dir.glob('lib/**/*') + %w[README.md LICENSE.md]
  spec.require_paths = ['lib']

  spec.add_dependency 'excon', '>= 0.109.0'
  spec.add_dependency 'faraday', '~> 2.0'
end
