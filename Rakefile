# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/uridium.rb'

Hoe.new('uridium', Uridium::VERSION) do |p|
   p.rubyforge_name = 'virtualp' # if different than lowercase project name
   p.developer('lmauri', 'lauri.arte@gmail.com')
end

namespace :test do
  require 'find'
  desc 'Run tests using multiruby'
  task :multiruby do
    Find.match("test/") {|p| File.basename(p) =~ /test_/ }.each do |tf|
      system("multiruby #{tf}")
    end
  end
end

require 'find'
module Find
  def match(*paths)
    matched = []
    find(*paths) { |path| matched << path if yield path }
    return matched
  end
  module_function :match
end	

# vim: syntax=Ruby
