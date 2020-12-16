# frozen_string_literal: true

require_relative 'lib/barion/version'

Gem::Specification.new do |spec|
  spec.name          = 'barion'
  spec.version       = Barion::VERSION
  spec.authors       = ['Péter Nagy']
  spec.email         = ['peter@bagy.consulting']

  spec.summary       = 'Barion payment solution for Ruby'
  spec.description   = 'Barion Payment Zrt. established in 2015 serve customers across the EEA. See https://barion.com for details.'
  spec.homepage      = 'https://github.com/Meter-Reader/barion'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.4.0')
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/Meter-Reader/barion'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_runtime_dependency 'rest-client', '~>2.1'
end
