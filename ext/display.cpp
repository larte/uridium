#include "uridium.h"
#ifndef OS_UNIX
#include <windows.h>
#endif

#include <SDL/SDL.h>
#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/glext.h>

extern "C"
{
static VALUE rb_display;

VALUE display_open_impl(VALUE self,
  VALUE rb_name, VALUE rb_width, VALUE rb_height, VALUE rb_fullscreen)
{
  SDL_Surface *screen;
  int width = NUM2INT(rb_width);
  int height = NUM2INT(rb_height);
  
  char* sdl_name = STR2CSTR(rb_name);
  SDL_WM_SetCaption(sdl_name, sdl_name);

  SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);

  screen = SDL_SetVideoMode(width, height, 32,
    (NUM2INT(rb_fullscreen) ? SDL_FULLSCREEN : 0) | SDL_OPENGL | SDL_DOUBLEBUF);

  if (screen == NULL)
  {
    printf("Unable to set video mode: %s\n", SDL_GetError());
    exit(1);
  }

  // Setup projection matrix
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glOrtho(0, width, height, 0, -1, 1);

  // Setup model view matrix
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  glDisable(GL_DEPTH);

  // Store the screen (SDL_Surface) to an instance variable of Display.
  rb_iv_set(self, "@sdl_surface", Data_Wrap_Struct(rb_display, 0, 0, screen));
}

VALUE display_sync_impl(VALUE self, VALUE interval)
{
#ifndef OS_UNIX
    typedef bool (APIENTRY *PFNWGLSWAPINTERVALFARPROC)(int);
    PFNWGLSWAPINTERVALFARPROC wglSwapIntervalEXT = 0;
    const char *extensions =(const char *) glGetString(GL_EXTENSIONS);
    if(strstr(extensions, "WGL_EXT_swap_control") == 0)
    {
	return 1;
    }
    else
    {

      wglSwapIntervalEXT = (PFNWGLSWAPINTERVALFARPROC)
      wglGetProcAddress("wglSwapIntervalEXT");

      if(wglSwapIntervalEXT)
        wglSwapIntervalEXT(NUM2INT(interval));
    
    return 0;
    }
#else
    return 1;
#endif
}      

/* TODO: return these from the Ruby side, as the info is stored there. */
VALUE display_size_impl(VALUE obj)
{
  SDL_Surface *screen;
  Data_Get_Struct(rb_iv_get(obj, "@sdl_surface"), SDL_Surface, screen);
  VALUE arr = rb_ary_new();
  rb_ary_push(arr, INT2NUM(screen->w));
  rb_ary_push(arr, INT2NUM(screen->h));
  return arr;
}

void init_display()
{
  rb_display = rb_define_class("Display", rb_cObject);
  rb_define_method(rb_display, "open_impl", (ruby_method*) &display_open_impl, 4);
  rb_define_method(rb_display, "sync_impl", (ruby_method*) &display_sync_impl, 1);
  rb_define_method(rb_display, "size", (ruby_method*) &display_size_impl, 0);
}

} // extern
