require 'mkmf'

COMMON_LIBS = %w[SDL2 SDL2_mixer freetype ftgl].freeze
NIX_LIBS = %w[GLU GL].freeze

HEADERS = { 'SDL2/SDL_mixer.h' => ['/usr', '/usr/local'],
            'ft2build.h' =>
           ['/usr/include/freetype2', '/usr/local/include/freetype2'] }.freeze

# Check libs
(COMMON_LIBS + NIX_LIBS).each do |l|
  have_library(l)
  find_library(l, nil, '/usr')
end

HEADERS.each do |header, paths|
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

if RUBY_PLATFORM =~ /darwin/
  # openGL
  $CPPFLAGS += ' -DOS_DARWIN'
end

create_makefile('uridium')
