/* -*-c++-*-
 *
 * gdi.cpp
 *
 * Created on 22.1.2008, 22:07:18
 *
 */
#include "display.h"
#include "gdi.h"
#include <SDL/SDL.h>
#include <GL/gl.h>

extern "C" VALUE gdi_init_impl(VALUE self, VALUE display)
{
    rb_iv_set(self, "@display", display);
    return self;
}

/*
 *   call-seq: scale() => #
 *
 */
extern "C" VALUE gdi_scale_impl(VALUE self, VALUE val)
{
    double s = NUM2DBL(val);
    glScalef(s, s, s);
    return Qnil;
}


/*
 *   call-seq: clear() => #
 *
 */
extern "C" VALUE gdi_clear_impl(int argc, VALUE* argv, VALUE self)
{
     VALUE rb_color;
     unsigned int color = 0x00000000;
     rb_scan_args(argc, argv, "01", &rb_color);
     if (!NIL_P(color))
     {
       color = NUM2UINT(rb_color);
     }
     
     glClearColor((color & 0x00ff0000) >> 16, (color & 0x0000ff00) >> 8, (color & 0x000000ff), (color & 0xff000000) >> 24);
     glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
     return Qnil;
}


/*
 *   call-seq: flip() => #
 *
 */
extern "C" VALUE gdi_flip_impl()
{
    SDL_GL_SwapBuffers();
    return Qnil;
}

/*
 *   call-seq: rotate(int angle) => #
 *       Rotate object around by <b>angle</b>.
 *
 */
extern "C" VALUE gdi_rotate_z_impl(VALUE val)
{
    int a = NUM2INT(val);
    glRotatef(a, 0, 0, 1);
    return Qnil;
}


static VALUE rb_gdi;

void init_gdi()
{
  rb_gdi = rb_define_class("Gdi", rb_cObject);
  rb_define_method(rb_gdi, "initialize", (ruby_method*) &gdi_init_impl, 1);
  rb_define_method(rb_gdi,"scale",(ruby_method*) &gdi_scale_impl, 1);
  rb_define_method(rb_gdi,"clear",(ruby_method*) &gdi_clear_impl, -1);
  rb_define_method(rb_gdi,"rotate_z",(ruby_method*) &gdi_rotate_z_impl, 1);
  rb_define_method(rb_gdi,"flip",(ruby_method*) &gdi_flip_impl, 0);
  
}
