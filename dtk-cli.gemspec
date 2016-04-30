require_relative 'lib/cli'
Gem::Specification.new do |spec| 
  spec.name        = 'dtk-cli'
  spec.version     = DTK::CLI::VERSION
  spec.author      = 'Reactor8'
  spec.email       = 'support@reactor8.com'
  spec.description = %q{Command line tool to interact with a DTK Server and DTK Service Catalog.}
  spec.summary     = %q{DTK CLI client for DTK server interaction.}
  spec.license     = 'Apache 2.0'
  spec.platform    = Gem::Platform::RUBY
  spec.required_ruby_version = Gem::Requirement.new('>= 1.9.3')

  spec.require_paths = ['lib']
  spec.files =  `git ls-files`.split("\n")

  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
end
