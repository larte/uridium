#include "uridium.h"
#ifdef OS_WIN32
#include <windows.h>
#endif

#ifndef OS_DARWIN
#include <SDL2/SDL.h>
#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/glext.h>
#else
#include <SDL2/SDL.h>
#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#include <OpenGL/glext.h>
#endif
extern "C"
{
  static VALUE rb_display;

  VALUE display_open_impl(VALUE self,
                          VALUE rb_name, VALUE rb_width, VALUE rb_height, VALUE rb_fullscreen)
  {
    SDL_Window *screen;
    int width = NUM2INT(rb_width);
    int height = NUM2INT(rb_height);

    char* sdl_name = STR2CSTR(rb_name);
    //  SDL_WM_SetCaption(sdl_name, sdl_name);

    SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 8);
    SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 8);
    SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 8);
    SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, 8);
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 16);
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);



    screen =  SDL_CreateWindow(sdl_name,
                               SDL_WINDOWPOS_UNDEFINED,
                               SDL_WINDOWPOS_UNDEFINED,
                               width, height,
                               (NUM2INT(rb_fullscreen) ? SDL_WINDOW_FULLSCREEN : 0)
                               | SDL_WINDOW_OPENGL);

    if (screen == NULL)
      {
        printf("Unable to set video mode: %s\n", SDL_GetError());
        exit(1);
      }

    SDL_GLContext gl_context = SDL_GL_CreateContext(screen);
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
    rb_iv_set(self, "@gl_context", Data_Wrap_Struct(rb_display, 0, 0, gl_context));

    return 1;
  }

  VALUE display_sync_impl(VALUE self, VALUE interval)
  {
#ifdef OS_WIN32
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
    SDL_Window *screen;
    Data_Get_Struct(rb_iv_get(obj, "@sdl_surface"), SDL_Window, screen);
    VALUE arr = rb_ary_new();
    int w, h;
    SDL_GetWindowSize(screen, &w, &h);
    rb_ary_push(arr, INT2NUM(w));
    rb_ary_push(arr, INT2NUM(h));
    return arr;
  }

  void init_display()
  {
    rb_display = rb_define_class_under(rb_uridium_module, "Display", rb_cObject);
    rb_define_method(rb_display, "open_impl", (ruby_method*) &display_open_impl, 4);
    rb_define_method(rb_display, "sync_impl", (ruby_method*) &display_sync_impl, 1);
    rb_define_method(rb_display, "size", (ruby_method*) &display_size_impl, 0);
  }

} // extern
