#ifndef URIDIUM_FONT_H
#define URIDIUM_FONT_H
#include "uridium.h"
#include <ruby.h>

typedef VALUE (ruby_method)(...);

VALUE font_render_impl(VALUE self, VALUE text);

extern "C" void init_font();

#endif
