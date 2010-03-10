# -*- ruby -*-
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'hanna/rdoctask'
require 'rake/testtask'
require 'fileutils'
include FileUtils


require 'find'
module Find
  def match(*paths)
    matched = []
    find(*paths) { |path| matched << path if yield path }
    return matched
  end
  module_function :match
end	


RbConfig = Config unless defined?(RbConfig)

NAME = "uridium"
REV = `hg tip`.split(/\n/)[0].match(/[0-9]+:[a-z0-9]*/).to_s.match(/^[0-9]+/).to_s.to_i
VERS = ENV['VERSION'] || "0.1"  + (REV ? ".#{REV}" : ".1")
PKG = "#{NAME}-#{VERS}"
BIN = "*.{bundle,jar,so,obj,pdb,lib,def,exp,class}"
ARCHLIB = "lib/#{::Config::CONFIG['arch']}"
CLEAN.include ["ext/#{BIN}", ARCHLIB, 'ext/Makefile', '*.gem', '.config', 'pkg']
RDOC_OPTS = ['--title', 'The Uridium Reference', '--main', 
             'README', '--inline-source', '-D']

PKG_FILES = %w(History.txt Manifest.txt README Rakefile) +
      Dir.glob("{bin,doc,test,lib}/**/*") + 
      Dir.glob("ext/*.{h,cpp,c,rb}") 


SPEC = 
  Gem::Specification.new do |s|
  s.name = NAME
  s.version = VERS
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.rdoc_options += RDOC_OPTS
  s.extra_rdoc_files = ["README", "History.txt", "Manifest.txt"]
  s.description = s.summary = "A few bindings for SDL"
  s.author = "Lauri and Niko"
  s.email = "lauri.arte@gmail.com"
  s.homepage = "http://uridium.virtualpope.com"
  s.files = PKG_FILES
  s.require_paths = [ARCHLIB, "lib"]
  s.extensions = FileList["ext/extconf.rb"].to_a
  s.bindir = "bin"
end

Rake::GemPackageTask.new(SPEC) do |p|
  p.need_tar = true
  p.gem_spec = SPEC
end

desc "Run tests."
Rake::TestTask.new do |t|
  t.libs << "test" << ARCHLIB
  t.test_files = FileList['test/test_*.rb']
  t.verbose = true
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'doc/rdoc'
  rdoc.options += RDOC_OPTS
  rdoc.main = "README"
  rdoc.rdoc_files.include("lib/*.rb", "ext/*.cpp")
  rdoc.rdoc_files.add ['README', 'Manifest.txt', 'History.txt']
end



namespace :test do
  require 'find'
  desc 'Run tests (using multiruby)'
  task :multiruby do
    Find.match("test/") {|p| File.basename(p) =~ /test_/ }.each do |tf|
      system("multiruby #{tf}")
    end
  end
end

task :install do
  sh %{rake package}
  sh %{sudo gem install pkg/#{NAME}-#{VERS}}
end

task :uninstall => [:clean] do
  sh %{sudo gem uninstall #{NAME}}
end

desc "Update the History.txt file."
task :update_history do 
  require 'time'
  require 'mercurial'
  hg = Mercurial::WorkingDirectory.new
  logs = hg.log
  File.open("History.txt","w") do |f|
    f.truncate(0)
    logs.each do |l|
      version = "0.1." + l.revision
      f.puts "=== #{version} / #{Time.parse(l.date).strftime("%Y-%m-%d")}"
      f.puts ""
      f.puts "Changes:"
      f.puts "\t* #{l.summary}"
      f.puts "\n"
    end
  end
end





# vim: syntax=Ruby
