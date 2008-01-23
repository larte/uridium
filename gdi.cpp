/* -*-c++-*-
 *
 * gdi.cpp
 *
 * Created on 22.1.2008, 22:07:18
 *
 */
#include "display.h"
#include "gdi.h"
#ifndef OS_UNIX
#include <sdl.h>
#include <gl/gl.h>
#else
#include <SDL/SDL.h>
#include <GL/gl.h>
#endif
extern "C" VALUE gdi_init_impl(VALUE display, VALUE self)
{
    rb_iv_set(self,"@display",display);
    return self;
}

/*
 *   call-seq: scale() => #
 *
 */
extern "C" VALUE gdi_scale_impl(VALUE val, VALUE self)
{
    double s = NUM2DBL(val);
    glScalef(s, s, s);
    return Qnil;
}


/*
 *   call-seq: clear() => #
 *
 */
extern "C" VALUE gdi_clear_impl()
{
     glClearColor(0, 0, 0, 0);
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
  rb_define_singleton_method(rb_gdi, "initialize",
			     (ruby_method*) &gdi_init_impl, 1);
  rb_define_method(rb_gdi,"scale",(ruby_method*) &gdi_scale_impl, 1);
  rb_define_method(rb_gdi,"clear",(ruby_method*) &gdi_clear_impl, 0);
  rb_define_method(rb_gdi,"rotate_z",(ruby_method*) &gdi_rotate_z_impl, 1);
  rb_define_method(rb_gdi,"flip",(ruby_method*) &gdi_flip_impl, 0);
  
}
