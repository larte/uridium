require 'mkmf'

have_library("opengl32")
have_library("glu32")
have_library("sdl")
have_library("sdlmain")

$objs = ["uridium.o", "display.o"]
create_makefile("uridium")
