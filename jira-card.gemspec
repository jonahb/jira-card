# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jira-card/version'

Gem::Specification.new do |spec|
  spec.name = 'jira-card'
  spec.version = JIRACard::VERSION
  spec.authors = ['Jonah Burke']
  spec.email = ['jonah@jonahb.com']
  spec.summary = 'Prints JIRA cards'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.0'
  spec.require_paths = ['lib']
  spec.files = Dir['LICENSE.txt', 'lib/**/*', 'bin/**/*']
  spec.executables << 'jira-card'

  spec.add_dependency 'highline', '~> 1.7'
  spec.add_dependency 'jira-ruby', '~> 0.1'
  spec.add_dependency 'thor', '~> 0.19'
end

