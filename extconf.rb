require 'mkmf'

#have_library("opengl32")
#have_library("glu32")
have_library("GLU")
have_library("GL")
have_library("SDL")
have_library("SDLmain")

$objs = ["uridium.o", "display.o"]
create_makefile("uridium")
