/* -*- c++ -*-

font.cpp

 Lauri Arte <lauri.arte@voondon.com>

Copyright (c) 2008 Voondon OY, Finland
                   All rights reserved

Created: Wed Mar 10 09:57:22 2010 larte
Last modified: Wed Mar 10 09:57:22 2010 larte

*/

#include "uridium.h"

#ifndef OS_DARWIN
#include <GL/gl.h>
#include <GL/glu.h>
#else
#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#endif


#include <ft2build.h>
#include <FTGL/ftgl.h>

extern "C"
{
static VALUE rb_font;

VALUE
font_initialize_impl(VALUE self, VALUE str, VALUE size)
{
    rb_iv_set(self,"@path", str);
    rb_iv_set(self,"@size", size);
    Check_Type(str, T_STRING);
    char *path = RSTRING_PTR(str);
    FTGLTextureFont* font = new FTGLTextureFont(path);
    font->FaceSize(NUM2INT(size));
    rb_iv_set(self, "@ftgl_font", Data_Wrap_Struct(rb_font, 0, 0, font));
    return self;
}

/*
 * call-seq: render(String, Array(x,y) = [0,0]) => #
 *
 *   Renders the font with lower left corner at point x,y
 */
VALUE
font_render_impl(VALUE argc, VALUE *argv, VALUE self)
{
    char *str = RSTRING_PTR(argv[0]);
    FTPoint p;
    if (argc == 1) { // only the text
        p = FTPoint(0.0, 0.0);
    }
    else {
        VALUE *carr = RARRAY_PTR(argv[1]);
        double x = NUM2DBL(carr[0]);
        double y = NUM2DBL(carr[1]);
        p = FTPoint(x,y);
    }

    void *font;
    Data_Get_Struct(rb_iv_get(self, "@ftgl_font"), FTGLTextureFont, font);

    glPushMatrix();
    glEnable(GL_TEXTURE_2D);
    glColor3f(1.0, 1.0, 1.0);
    glScalef(1, -1, 1);
    ((FTFont*) font)->Render(str, -1, p); // FTPoint(NUM2DBL(xcoord), NUM2DBL(ycoord)));
    glPopMatrix();

    return Qnil;
}

void init_font()
{
  rb_font = rb_define_class_under(rb_uridium_module, "Font", rb_cObject);
  rb_define_method(rb_font, "initialize", (ruby_method*) &font_initialize_impl, 2);
  rb_define_method(rb_font,"render",(ruby_method*) &font_render_impl, -1);
}

} // extern
