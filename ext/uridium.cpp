#include "uridium.h"
#include <SDL/SDL.h>

extern "C"
{

VALUE uridium_init_impl()
{
  if (SDL_Init(SDL_INIT_VIDEO) < 0)
  {
    printf("Unable to init SDL: %s\n", SDL_GetError());
    exit(1);
  }
  return 0;
}

VALUE uridium_destroy_impl()
{
  SDL_Quit();
  return 0;
}

/* Module forward declarations. */
void init_display();
void init_gdi();
void init_font();
void init_event();

static VALUE rb_uridium;
void Init_uridium()
{
  rb_uridium = rb_define_class("Uridium", rb_cObject);
  rb_define_singleton_method(rb_uridium, "init", (ruby_method*) &uridium_init_impl, 0);
  rb_define_singleton_method(rb_uridium, "destroy", (ruby_method*) &uridium_destroy_impl, 0);

  init_display();
  init_gdi();
  init_font();
  init_event();
}

} // extern
