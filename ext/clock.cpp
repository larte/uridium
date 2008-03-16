/* -*- c++ -*-

clock.cpp

-- clock

*/
#include "uridium.h"


#include <SDL/SDL.h>

extern "C"
{

static VALUE rb_clock;

VALUE ticks(VALUE self)
{
  return UINT2NUM(SDL_GetTicks());
}

VALUE sleep(VALUE self, VALUE time)
{
  SDL_Delay(NUM2UINT(time));
  return Qnil;
}

void init_clock()
{
  rb_clock = rb_define_class("Clock", rb_cObject);
	
  rb_define_singleton_method(rb_clock, "ticks", (ruby_method*) &ticks, 0);
  rb_define_singleton_method(rb_clock, "sleep", (ruby_method*) &sleep, 1);
}


} // extern
