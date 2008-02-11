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

static VALUE rb_display;

/*
static VALUE display_alloc(VALUE self)
{
        SDL_Surface *s = (SDL_Surface *)malloc(sizeof(SDL_Surface));
        VALUE obj;
        obj = Data_Wrap_Struct(self, 0, free, s);
        return obj;
}
*/
extern "C" VALUE display_open_impl(VALUE self,
  VALUE name, VALUE width, VALUE height, VALUE fullscreen)
{
  SDL_Surface *screen;
//  Data_Get_Struct(self, SDL_Surface, screen);
  
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

  return Data_Wrap_Struct(rb_display, 0, 0, screen);
 
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

extern "C" VALUE display_size_impl(VALUE obj)
{
        SDL_Surface *screen;
        Data_Get_Struct(obj, SDL_Surface, screen);
        VALUE arr = rb_ary_new();
        rb_ary_push(arr, INT2NUM(screen->w));
        rb_ary_push(arr, INT2NUM(screen->h));
        return arr;
}



void init_display()
{
  rb_display = rb_define_class("Display", rb_cObject);
  //rb_define_alloc_func(rb_display, display_alloc);
  rb_define_method(rb_display, "initialize", (ruby_method*) &display_open_impl, 4);
  rb_define_method(rb_display, "sync", (ruby_method*) &display_sync_impl, 1);

  rb_define_method(rb_display, "size", (ruby_method*) &display_size_impl, 0);
  
}
