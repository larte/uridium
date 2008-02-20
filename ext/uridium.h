#ifndef URIDIUM_H
#define URIDIUM_H

#include <ruby.h>

#include "display.h"
#include "gdi.h"
#include "font.h"
#include "event.h"

typedef VALUE (ruby_method)(...);

// Modules
static VALUE rb_uridium;
static VALUE rb_display;
static VALUE rb_gdi;
static VALUE rb_font;
static VALUE rb_event;
static VALUE rb_key_event;

// methods for ruby < 1.8.6 
#ifndef RSTRING_LEN
#define RSTRING_LEN(x) RSTRING(x)->len
#endif

#ifndef RSTRING_PTR
#define RSTRING_PTR(x) RSTRING(x)->ptr
#endif

#endif
