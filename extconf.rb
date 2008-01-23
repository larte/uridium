require 'mkmf'

c_libs = []
cpp_libs = []

# if on linux check ruby_platform
if RUBY_PLATFORM =~ /linux/ || RUBY_PLATFORM =~ /BSD/
  CONFIG['CC'] = 'g++'	
  $CFLAGS += " -DOS_UNIX "
  c_libs << "GLU"
  c_libs << "GL"
  c_libs << "SDL"
  c_libs << "SDLmain"
  c_libs << "freetype"
  c_libs << "ftgl"

  $CFLAGS += "-I/usr/include/FTGL -I/usr/include/freetype2 -I/usr/local/include/FTGL -I/usr/local/include/freetype2"
  
else #win32
  c_libs << "opengl32"
  c_libs << "glu32"  
  c_libs << "sdl"  
  c_libs << "sdlmain"
end


c_libs.each{|lib| have_library(lib) }

$objs = ["uridium.o", "display.o","gdi.o","font.o"]
create_makefile("uridium")
