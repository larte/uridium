require 'mkmf'

c_libs = []
cpp_libs = []
headers = []

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
  headers << "SDL/SDL_mixer.h"
  $CFLAGS += "-I/usr/include/FTGL -I/usr/include/freetype2 "
  $CFLAGS += "-I/usr/local/include/FTGL -I/usr/local/include/freetype2"

elsif RUBY_PLATFORM =~ /mingw32/  
  CONFIG['CC'] = 'g++'
  CONFIG['LDSHARED'] = 'g++ -shared -s'
  c_libs << "opengl32"
  c_libs << "glu32"
  c_libs << "SDL"
  c_libs << "SDLmain"
  c_libs << "SDL_mixer"
  c_libs << "freetype"
  c_libs << "ftgl"

  headers << "SDL/SDL_mixer.h"

else
  raise "Unsupported platform: #{RUBY_PLATFORM}"
end

missing = [];
c_libs.each{ |lib| 
  if !have_library(lib)
    missing << lib
  end
}

headers.each{ |header|
  if !have_header(header)
    missing << header
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
