require 'mkmf'

c_libs = []
cpp_libs = []

puts "Configuring for #{RUBY_PLATFORM}..."
if RUBY_PLATFORM =~ /linux/ || RUBY_PLATFORM =~ /BSD/
  CONFIG['CC'] = 'g++'	
  $CFLAGS += " -DOS_UNIX "
  c_libs << "GLU"
  c_libs << "GL"
  c_libs << "SDL"
  c_libs << "SDLmain"
  c_libs << "freetype"
  c_libs << "ftgl"

  $CFLAGS += "-I/usr/include/FTGL -I/usr/include/freetype2 "
  $CFLAGS += "-I/usr/local/include/FTGL -I/usr/local/include/freetype2"

elsif RUBY_PLATFORM =~ /mingw32/  
  CONFIG['CC'] = 'g++'
  CONFIG['LDSHARED'] = 'g++ -shared -s'
  c_libs << "opengl32"
  c_libs << "glu32"
  c_libs << "SDLmain"
  c_libs << "SDL"  
  c_libs << "freetype"
  c_libs << "ftgl"
else
  raise "Unsupported platform: #{RUBY_PLATFORM}"
end

missing = [];
c_libs.each{ |lib| 
  if !have_library(lib)
    missing << lib
  end
}

if !missing.empty?
puts "Missing dependencies:"
  missing.each do |lib|
    puts "\t#{lib}"
  end
  puts "Exiting..."
  exit;
end

create_makefile("uridium")
