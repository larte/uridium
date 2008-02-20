/* -*-c++-*-
 *
 * gdi.cpp
 *
 * Created on 22.1.2008, 22:07:18
 *
 */
#include "display.h"
#include "gdi.h"
#include "font.h"
#include <SDL/SDL.h>
#include <GL/gl.h>

extern "C" VALUE gdi_init_impl(VALUE self, VALUE display)
{
    rb_iv_set(self, "@display", display);
    return self;
}

extern "C" VALUE gdi_trans0_impl(VALUE self)
{
    glLoadIdentity();
    return Qnil;
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
     if (!NIL_P(rb_color))
     {
       color = NUM2UINT(rb_color);
     }
     
     glClearColor(
        ((color & 0x00ff0000) >> 16) / 255.0f,
        ((color & 0x0000ff00) >> 8) / 255.0f,
        ((color & 0x000000ff)) / 255.0f,
        ((color & 0xff000000) >> 24) / 255.0f
     );
     glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
     return Qnil;
}

/*
 *   call-seq: flip() => #
 *
 */
extern "C" VALUE gdi_flip_impl(VALUE self)
{
    SDL_GL_SwapBuffers();
    return Qnil;
}

/*
 *   call-seq: rotate(int angle) => #
 *       Rotate object around by <b>angle</b>.
 *
 */
extern "C" VALUE gdi_rotate_z_impl(VALUE self, VALUE val)
{
    float a = NUM2DBL(val);
    glRotatef(a, 0, 0, 1);
    return Qnil;
}

extern "C" VALUE gdi_draw_line(VALUE self, VALUE coord1, VALUE coord2, VALUE colour)
{
	float x1 = NUM2DBL(rb_ary_pop(coord1));
	float y1 = NUM2DBL(rb_ary_pop(coord1));
	float x2 = NUM2DBL(rb_ary_pop(coord2));
	float y2 = NUM2DBL(rb_ary_pop(coord2));
	float red = NUM2DBL(rb_ary_pop(colour));
	float green = NUM2DBL(rb_ary_pop(colour));
	float blue = NUM2DBL(rb_ary_pop(colour));

	SDL_GL_SetAttribute(SDL_GL_RED_SIZE,     1);
	SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE,   1);
	SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE,    1);
	SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);

	glColor3f(red, green, blue);

	glBegin(GL_LINES);
	glVertex2f(x1, y1);
	glVertex2f(x2, y2);
	glEnd();
	
	return Qnil;
}

extern "C" VALUE gdi_draw_text(VALUE self, VALUE font, VALUE text)
{
    font_render_impl(font, text);
    return Qnil;
}

void init_gdi()
{
  rb_gdi = rb_define_class("Gdi", rb_cObject);
  rb_define_method(rb_gdi, "initialize", (ruby_method*) &gdi_init_impl, 1);
  rb_define_method(rb_gdi, "trans0", (ruby_method*) &gdi_trans0_impl, 0);
  rb_define_method(rb_gdi, "scale",(ruby_method*) &gdi_scale_impl, 1);
  rb_define_method(rb_gdi, "clear",(ruby_method*) &gdi_clear_impl, -1);
  rb_define_method(rb_gdi, "rotate_z",(ruby_method*) &gdi_rotate_z_impl, 1);
  rb_define_method(rb_gdi, "flip",(ruby_method*) &gdi_flip_impl, 0);
  rb_define_method(rb_gdi, "draw_line", (ruby_method*) &gdi_draw_line, 3);
  rb_define_method(rb_gdi, "draw_text", (ruby_method*) &gdi_draw_text, 2);
}
