#ifndef URIDIUM_H
#define URIDIUM_H

#include <SDL2/SDL.h>
#include <ruby.h>

typedef VALUE (ruby_method)(...);

static VALUE rb_uridium_module = rb_define_module("LibUridium");

#ifdef DEBUG
#define LOG(format, ...) \
  SDL_Log((const char*) format, ##__VA_ARGS__);
#else
#define LOG(format, ...) \
  ((void)0);
#endif


// methods for ruby < 1.8.6
#ifndef RSTRING_LEN
#define RSTRING_LEN(x) RSTRING(x)->len
#endif

#ifndef RSTRING_PTR
#define RSTRING_PTR(x) RSTRING(x)->ptr
#endif

#ifndef STR2CSTR
#define STR2CSTR(x) StringValuePtr(x)
#endif

#endif
