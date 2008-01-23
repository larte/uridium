/* -*-c++-*-
 *
 * font.cpp
 *
 * Created on 23.1.2008, 18:27:28
 *
 */
#include "display.h"
#include "font.h"
#ifndef OS_UNIX
#include <gl/gl.h>
#include <gl/glu.h>
#include <FTGLTextureFont.h>
#else
#include <GL/gl.h>
#include <GL/glu.h>
#include <ft2build.h>
#include <FTGL/FTGLOutlineFont.h>
#include <FTGL/FTGLPolygonFont.h>
#include <FTGL/FTGLBitmapFont.h>
#include <FTGL/FTGLTextureFont.h>
#include <FTGL/FTGLPixmapFont.h>

#endif



VALUE font_initialize_impl(VALUE str, VALUE size, VALUE self)
{
    rb_iv_set(self,"@path", str);
    rb_iv_set(self,"@size", size);
    char *path = RSTRING(str)->ptr;
    FTGLTextureFont* font = new FTGLTextureFont(path);
    font->FaceSize(INT2NUM(size));
    return INT2FIX((unsigned int) font);
}

/*
 *   call-seq: clear() => #
 *
 */

VALUE font_render_impl(VALUE font_num, VALUE text, VALUE self)
{
    char *str = RSTRING(text)->ptr;
    unsigned int font = NUM2UINT(font_num);
    glPushMatrix();
    glEnable(GL_TEXTURE_2D);
    glColor3f(1.0, 1.0, 1.0);
    ((FTFont*) font)->Render(str);
    glPopMatrix();

    return Qnil;
}


static VALUE rb_font;

void init_font()
{
  rb_font = rb_define_class("Font", rb_cObject);
  rb_define_singleton_method(rb_font, "new",
			     (ruby_method*) &font_initialize_impl, 2);
  rb_define_method(rb_font,"render",(ruby_method*) &font_render_impl, 2);
  
}
