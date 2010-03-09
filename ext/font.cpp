#include "uridium.h"

#include <GL/gl.h>
#include <GL/glu.h>
#include <ft2build.h>
#include <FTGL/FTGLOutlineFont.h>
#include <FTGL/FTGLPolygonFont.h>
#include <FTGL/FTGLBitmapFont.h>
#include <FTGL/FTGLTextureFont.h>
#include <FTGL/FTGLPixmapFont.h>

extern "C"
{
static VALUE rb_font;

VALUE font_initialize_impl(VALUE self, VALUE str, VALUE size)
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
 *   call-seq: clear() => #
 *
 */
VALUE font_render_impl(VALUE self, VALUE text, VALUE xcoord, VALUE ycoord)
{
    char *str = RSTRING_PTR(text);
    void *font;
    Data_Get_Struct(rb_iv_get(self, "@ftgl_font"), FTGLTextureFont, font);
    
    glPushMatrix();
    glEnable(GL_TEXTURE_2D);
    glColor3f(1.0, 1.0, 1.0);
    glScalef(1, -1, 1);
    ((FTFont*) font)->Render(str, -1, FTPoint(NUM2DBL(xcoord), NUM2DBL(ycoord)));
    glPopMatrix();

    return Qnil;
}

void init_font()
{
  rb_font = rb_define_class("Font", rb_cObject);
  rb_define_method(rb_font, "initialize", (ruby_method*) &font_initialize_impl, 2);
  rb_define_method(rb_font,"render",(ruby_method*) &font_render_impl, 3);
}

} // extern
