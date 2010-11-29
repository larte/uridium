/* -*- c++ -*-

clock.cpp

-- clock

*/
#include "uridium.h"


#include <SDL2/SDL.h>

extern "C"
{

static VALUE rb_clock;

VALUE ticks_impl(VALUE self)
{
  return INT2FIX(SDL_GetTicks());
}

VALUE sleep_impl(VALUE self, VALUE time)
{
      SDL_Delay(FIX2UINT(time));
      return Qnil;
}

void init_clock()
{
  rb_clock = rb_define_class_under(rb_uridium_module, "Clock", rb_cObject);

  rb_define_singleton_method(rb_clock, "ticks", (ruby_method*) &ticks_impl, 0);
  rb_define_singleton_method(rb_clock, "sleep", (ruby_method*) &sleep_impl, 1);
}


} // extern
