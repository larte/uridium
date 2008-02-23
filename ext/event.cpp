#include "uridium.h"

#include <SDL/SDL.h>

extern "C"
{
static VALUE rb_event;
static VALUE rb_key_event;

VALUE event_poll_impl()
{
  SDL_Event event;
  if (SDL_PollEvent(&event))
  {
    VALUE ruby_event;
    switch (event.type)
    {
      case SDL_KEYDOWN:
      case SDL_KEYUP:
      {
        // Create a KeyEvent.
        VALUE args[] = {
          event.key.state == SDL_PRESSED ? Qtrue : Qfalse,
          INT2NUM(event.key.keysym.sym)
        };
        ruby_event = rb_class_new_instance(2, args, rb_key_event);
        return ruby_event;
        break;
      }
      default:
        // Silently ignore the unsupported event.
        ;
    }
  }
  return Qnil;
}

VALUE event_poll_all_impl()
{
  // TODO: Poll events while there are some left.
  // Return an array of events.
  return Qnil;
}

/**
 * Key event.
 */
VALUE key_event_init_impl(VALUE self, VALUE state, VALUE symbol)
{
  rb_iv_set(self, "@pressed", state);
  rb_iv_set(self, "@symbol", symbol);
  return self;
}

void init_event()
{
  rb_event = rb_define_class("Event", rb_cObject);

  rb_key_event = rb_define_class("KeyEvent", rb_event);
  rb_define_method(rb_key_event, "initialize", (ruby_method*) &key_event_init_impl, 2);

  rb_define_singleton_method(rb_event, "poll",
    (ruby_method*) &event_poll_impl, 0);

  rb_define_singleton_method(rb_event, "poll_all",
    (ruby_method*) &event_poll_all_impl, 0);
}

} // extern
