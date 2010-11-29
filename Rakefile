require 'bundler/gem_tasks'
require 'rubygems'
require 'bundler/gem_helper'
require 'rubocop'
require 'rubocop/rake_task'
require 'yard'

Bundler::GemHelper.install_tasks

# task default: :spec

require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb']
  t.options = ['--no-private', '--one-file']
end
