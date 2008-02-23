#ifndef URIDIUM_H
#define URIDIUM_H

#include <SDL/SDL.h>
#include <ruby.h>

typedef VALUE (ruby_method)(...);

// methods for ruby < 1.8.6 
#ifndef RSTRING_LEN
#define RSTRING_LEN(x) RSTRING(x)->len
#endif

#ifndef RSTRING_PTR
#define RSTRING_PTR(x) RSTRING(x)->ptr
#endif

#endif
