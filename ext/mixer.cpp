/* -*- c++ -*-

mixer.cpp

-- to play sounds

Created: Sun Feb 24 17:11:24 2008 lauri
Last modified: Sun Feb 24 17:11:24 2008 lauri

*/
#include "uridium.h"


#include <SDL/SDL.h>
#include <SDL/SDL_mixer.h>

extern "C"
{

static VALUE rb_mixer;

VALUE init_mixer_impl(VALUE self, VALUE freq, VALUE format,
		      VALUE chan, VALUE chunksize)
{
    if( Mix_OpenAudio( NUM2INT(freq),NUM2UINT(format),NUM2INT(chan),
		       NUM2INT(chunksize) ) < 0 ){
	    printf("Open audio failed: %s",SDL_GetError());
    }

    return Qnil;
}

	
void init_mixer()
{

  rb_mixer = rb_define_class("Mixer", rb_mixer);
	
  rb_define_method(rb_mixer, "initialize",
    (ruby_method*) &init_mixer_impl, 4);

	
}


} // extern
