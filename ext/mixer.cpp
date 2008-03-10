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

VALUE init_mixer_impl(VALUE self, VALUE freq,
		      VALUE chan, VALUE chunksize)
{
	/* Initialization */
	if(SDL_InitSubSystem(SDL_INIT_AUDIO) == -1){
		// SDL Audio subsystem could not be started
		printf("SDL audio subsystem could not be started");
	}
	
	if( Mix_OpenAudio( NUM2INT(freq),
			   MIX_DEFAULT_FORMAT,
			   NUM2INT(chan),
			   NUM2INT(chunksize) ) < 0 ){
	    printf("Open audio failed: %s",SDL_GetError());
    }

    return Qnil;
}

VALUE play_wav_impl(VALUE self, VALUE path)
{

	Check_Type(path, T_STRING);
	char *file = RSTRING_PTR(path);

	Mix_Chunk *sound = NULL;
	sound = Mix_LoadWAV(file);
	if(sound == NULL){
		fprintf(stderr, "Unable to load wav file: %s\n", file);
	}
	int channel;
 
	channel = Mix_PlayChannel(-1, sound, 0);
	if(channel == -1) {
	    fprintf(stderr, "Unable to play WAV file: %s\n", Mix_GetError());
	}
       
	return Qnil;
}

VALUE stop_play_wav_impl(VALUE self)
{
	printf("not implemented\n");
}
	
void init_mixer()
{
  rb_mixer = rb_define_class("Mixer", rb_cObject);
	
  rb_define_method(rb_mixer, "initialize",
		   (ruby_method*) &init_mixer_impl, 3);
  rb_define_method(rb_mixer, "play_sound",
		   (ruby_method*) &play_wav_impl, 1);
  rb_define_method(rb_mixer, "stop_playing",
		   (ruby_method*) &stop_play_wav_impl, 0);

}


} // extern
