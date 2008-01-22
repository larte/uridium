require 'mkmf'

# if on linux check ruby_platform
if RUBY_PLATFORM =~ /linux/
  CONFIG['CC'] = 'g++'	
  $CFLAGS += " -DOS_UNIX"
  have_library("GLU")
  have_library("GL")
  have_library("SDL")
  have_library("SDLmain")
end

#have_library("opengl32")
#have_library("glu32")


$objs = ["uridium.o", "display.o"]
create_makefile("uridium")
