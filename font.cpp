/* -*- c++ -*-

font.cpp

Created: Mon Feb  4 18:19:55 2008 lauri
Last modified: Mon Feb  4 18:19:55 2008 lauri

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
    printf("got font %s\n",path);
    FTGLTextureFont* font = new FTGLTextureFont(path);
    font->FaceSize(INT2NUM(size));
    Data_Wrap_Struct(self, 0 ,free, font);
    return self;
}

/*
 *   call-seq: clear() => #
 *
 */

VALUE font_render_impl(VALUE text, VALUE self)
{
    char *str = RSTRING(text)->ptr;

    
    void *font;
    Data_Get_Struct(self, FTGLTextureFont, font);
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
  rb_define_method(rb_font,"render",(ruby_method*) &font_render_impl, 1);

}
