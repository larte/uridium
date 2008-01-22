#include "uridium.h"
#ifndef OS_UNIX
#include <windows.h>
#include <sdl.h>
#include <gl/gl.h>
#include <gl/glu.h>
#else
#include <SDL/SDL.h>
#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/glext.h>
#endif

extern "C" VALUE display_open_impl(VALUE self,
  VALUE name, VALUE width, VALUE height, VALUE fullscreen)
{
  SDL_Surface *screen;

  char* sdl_name = STR2CSTR(name);
  SDL_WM_SetCaption(sdl_name, sdl_name);

  screen = SDL_SetVideoMode(NUM2INT(width), NUM2INT(height), 32,
    (NUM2INT(fullscreen) ? SDL_FULLSCREEN : 0) | SDL_OPENGL | SDL_DOUBLEBUF);

  if (screen == NULL)
  {
    printf("Unable to set video mode: %s\n", SDL_GetError());
    exit(1);
  }

  // Setup projection matrix
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluOrtho2D(0, width, 0, height);

  // Setup model view matrix
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  rb_iv_set(self, "@sdl_surface", INT2NUM((unsigned int) screen));
  return Qnil;
}

extern "C" VALUE display_sync_impl(VALUE self, VALUE interval)
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

      
      wglSwapIntervalEXT = (PFNWGLSWAPINTERVALFARPROC)
	  glGetProcAddress("wglSwapIntervalEXT");
      
      if(wglSwapIntervalEXT)
	wglSwapIntervalEXT(NUM2INT(interval));
    
    return 0;
    }
#else
    return 1;
#endif
}      

static VALUE rb_display;

void init_display()
{
  rb_display = rb_define_class("Display", rb_cObject);
  rb_define_method(rb_display, "open_impl", (ruby_method*) &display_open_impl, 4);
  rb_define_method(rb_display, "sync_impl", (ruby_method*) &display_sync_impl, 1);
}
