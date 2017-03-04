source 'https://rubygems.org'

group :test do
  gem 'metadata-json-lint'
  gem 'puppet', ENV['PUPPET_VERSION'] || '~> 3.8.0'
  gem 'puppet-blacksmith'
  gem 'puppet-lint-absolute_classname-check'
  gem 'puppet-lint-classes_and_types_beginning_with_digits-check'
  gem 'puppet-lint-leading_zero-check'
  gem 'puppet-lint-trailing_comma-check'
  gem 'puppet-lint-unquoted_string-check'
  gem 'puppet-lint-variable_contains_upcase'
  gem 'puppet-lint-version_comparison-check'
  gem 'puppetlabs_spec_helper'
  gem 'rake'
  gem 'rubocop'
  gem 'rspec'
  gem 'rspec-puppet', git: 'https://github.com/rodjek/rspec-puppet.git'
  gem 'rspec-puppet-facts'
end

group :development do
  gem 'guard-rake'
  gem 'travis'
  gem 'travis-lint'
end

group :system_tests do
  gem 'beaker'
  gem 'beaker-rspec'
end
