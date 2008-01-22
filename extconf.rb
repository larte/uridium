require 'mkmf'

# if on linux check ruby_platform
if RUBY_PLATFORM =~ /linux/
  CONFIG['CC'] = 'g++'	
  $CFLAGS += " -DOS_UNIX"
  have_library("GLU")
  have_library("GL")
  have_library("SDL")
  have_library("SDLmain")
else #win32
  have_library("opengl32")
  have_library("glu32")
  have_library("sdl")
  have_library("sdlmain")
end

$objs = ["uridium.o", "display.o","gdi.o"]
create_makefile("uridium")
