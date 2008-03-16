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
static VALUE rb_sound;

/*
 * call-seq:
 *         new(int frequency, int channels, int buffer) #=> Mixer
 *
 * Create a new mixer.
 */
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
	
VALUE init_sound_impl(VALUE self, VALUE path)
{
	Check_Type(path, T_STRING);
	char *file = RSTRING_PTR(path);

	Mix_Chunk *sound = NULL;
	sound = Mix_LoadWAV(file);
	if(sound == NULL){
		fprintf(stderr, "Unable to load wav file: %s\n", file);
	}
	rb_iv_set(self, "@chunk", Data_Wrap_Struct(rb_sound, 0, 0, sound));
	return self;
}
/*
 * no-doc
 */
VALUE play_sound_impl(VALUE self, VALUE samples, VALUE channelnum)
{
 	Mix_Chunk *sound = NULL;
	int num_samples = FIX2INT(samples);
	int num_channel = FIX2INT(channelnum); 
	Data_Get_Struct(rb_iv_get(self, "@chunk"), Mix_Chunk, sound);
	int channel = Mix_PlayChannel(num_channel, sound, num_samples);
	if(channel == -1) {
	    fprintf(stderr, "Unable to play WAV file: %s\n", Mix_GetError());
	}	
	return Qnil;
}

	
void init_mixer()
{
  rb_mixer = rb_define_class("Mixer", rb_cObject);
  rb_sound = rb_define_class("Sound", rb_cObject);
  
  rb_define_method(rb_mixer, "mixer_init_impl",
		   (ruby_method*) &init_mixer_impl, 3);

  // Sound class

  rb_define_method(rb_sound, "initialize",
		   (ruby_method*) &init_sound_impl, 1);

  rb_define_method(rb_sound, "play_sound_impl",
		   (ruby_method*) &play_sound_impl, 2);
}
	


} // extern
