lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'uridium'
  spec.version       = LibUridium::VERSION
  spec.authors       = ["larte"]
  spec.email         = ["lauri.arte@gmail.com"]
  spec.description   = "SDL bindings for ruby"
  spec.summary       = spec.description
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.required_ruby_version = "> 2.2"

  spec.files         = %w(README.md) + Dir.glob("{bin,doc,lib}/**/*") +
                       Dir.glob("ext/*.{h,cpp,c,rb}")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.bindir = "bin"
  spec.extensions = %w[ext/extconf.rb]

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = ''
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end


  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", '~> 11.3'
  spec.add_development_dependency 'rubocop', '~> 0.52'
  spec.add_development_dependency 'yard', '~> 0.9'

end
