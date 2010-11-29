#include "uridium.h"
#include <SDL2/SDL.h>

extern "C"
{
static VALUE rb_uridium;

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
void init_clock();
void init_mixer();

void Init_uridium()
{

  rb_uridium = rb_define_class_under(rb_uridium_module, "Uridium", rb_cObject);
  rb_define_singleton_method(rb_uridium, "init", (ruby_method*) &uridium_init_impl, 0);
  rb_define_singleton_method(rb_uridium, "destroy", (ruby_method*) &uridium_destroy_impl, 0);

  init_display();
  init_gdi();

  init_font();

  init_event();
  init_clock();
  init_mixer();
}

} // extern
