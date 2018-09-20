# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'hive/version'

Gem::Specification.new do |s|
  s.name = 'hivemind-ruby'
  s.version = Hive::VERSION
  s.authors = ['Anthony Martin']
  s.email = ['anthony@steemit.com']
  
  s.summary = 'STEEM Hivemind for Ruby.'
  s.description = 'If you run your own `hivemind` node, you can leverage your local subset of the blockchain you\'ve synchronied to Postgres using ActiveRecord.'
  s.homepage = 'https://github.com/steemit/hivemind-ruby'
  s.license = 'MIT'
  
  s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test)/}) }
  s.bindir = 'bin'
  s.executables = 'hivemind-ruby'
  s.require_paths = ['lib']
  
  # Ruby Make (interprets the Rakefile DSL).
  s.add_development_dependency 'rake', '~> 12.3', '>= 12.3.1'
  
  # Minitest is a simple unittest suite.
  s.add_development_dependency 'minitest', '~> 5.10', '>= 5.10.3'
  
  # Provies a way to run an individual test by giving a line number argument.
  s.add_development_dependency 'minitest-line', '~> 0.6', '>= 0.6.4'
  
  # Forces all tests to do at least one assert/refute.
  s.add_development_dependency 'minitest-proveit', '~> 1.0', '>= 1.0.0'
  
  # Simple Code Coverage.
  s.add_development_dependency 'simplecov', '~> 0.15', '>= 0.15.1'
  
  # Rails style Object Relational Mapping
  s.add_dependency 'activerecord', ['>= 4', '< 6']
  
  # Postgres AR driver.
  s.add_dependency 'pg', '~> 0.21'
  
  # Deals with hive schema use of AR keywords in columns like hive_blocks.hash.
  s.add_dependency 'safe_attributes'
  
  # Deals with hive schema use of composite primary keys.
  s.add_dependency 'composite_primary_keys'
end
