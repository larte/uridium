require 'mkmf'


COMMON_LIBS = %w[SDL2 SDL2_mixer freetype ftgl].freeze
NIX_LIBS = %w[GLU GL].freeze
DARWIN_LIBS = %w[]

HEADERS = { 'SDL2/SDL_mixer.h' => ['/usr', '/usr/local'],
            'ft2build.h' =>
           ['/usr/include/freetype2', '/usr/local/include/freetype2'] }.freeze

NIX_HEADERS = {
  'GL/gl.h' => ['/usr', '/usr/local'],
  'GL/glu.h' => ['/usr', '/usr/local'],
  'GL/glext.h' => ['/usr', '/usr/local']
}
DARWIN_HEADERS = {
  'OpenGL/gl.h' => ['/usr', '/usr/local'],
  'OpenGL/glu.h' => ['/usr', '/usr/local'],
  'OpenGL/glext.h' => ['/usr', '/usr/local']
}

if RUBY_PLATFORM =~ /darwin/
  # openGL
  $CPPFLAGS += ' -DOS_DARWIN'
  libs = COMMON_LIBS + DARWIN_LIBS
  headers = HEADERS.merge DARWIN_HEADERS
else
  libs = COMMON_LIBS + NIX_LIBS
  headers = HEADERS.merge NIX_HEADERS
end




# Check libs
missing = []
libs.each do |l|
  missing << l unless have_library(l)
end

abort "can't find #{missing.join(", ")} libs" unless missing.empty?

headers.each do |header, paths|
  find_header(header, *paths)
end

cpp_unkown_warnflags = %w[-Winplicit-init
                          -Wimplicit-int
                          -Wno-self-assign
                          -Wno-constant-logical-operand
                          -Wno-parentheses-equality
                          -Wimplicit-function-declaration
                          -Wdeclaration-after-statement].freeze

cpp_unkown_warnflags.each do |f|
  CONFIG['warnflags'].slice!(/ #{f}/)
end


create_makefile('uridium')
