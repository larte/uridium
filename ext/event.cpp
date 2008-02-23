#include "uridium.h"

#include <SDL/SDL.h>

extern "C"
{
/* Constants. */
enum event_mask
{
  TYPE_ACTIVATION = 0x01,
  TYPE_KEY        = 0x02
};

static VALUE rb_event;
static VALUE rb_activation_event;
static VALUE rb_key_event;

VALUE event_resolve(SDL_Event &event)
{
  VALUE ruby_event;
  switch (event.type)
  {
    case SDL_ACTIVEEVENT:
    {
      // Create an ActivationEvent
      VALUE args[] = {
        event.active.gain == 1 ? Qtrue : Qfalse
      };
      ruby_event = rb_class_new_instance(1, args, rb_activation_event);
      return ruby_event;
      break;
    }

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
      // Unsupported event.
      return Qnil;
  }
}

VALUE event_poll_impl()
{
  SDL_Event event;
  if (SDL_PollEvent(&event))
  {
    return event_resolve(event);
  }
  return Qnil;
}

VALUE event_poll_all_impl()
{
  VALUE events = rb_ary_new();
  VALUE ruby_event;  
  SDL_Event event;

  while (SDL_PollEvent(&event))
  {
    ruby_event = event_resolve(event);
    if (ruby_event != Qnil)
    {
      rb_ary_push(events, ruby_event);
    }
  }
  return events;
}

/**
 * Activation event.
 */
VALUE activation_event_init_impl(VALUE self, VALUE focus)
{
  rb_iv_set(self, "@focus", focus);
  return self;
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

  rb_activation_event = rb_define_class("ActivationEvent", rb_event);
  rb_define_method(rb_activation_event, "initialize",
    (ruby_method*) &activation_event_init_impl, 1);

  rb_key_event = rb_define_class("KeyEvent", rb_event);
  rb_define_method(rb_key_event, "initialize",
    (ruby_method*) &activation_event_init_impl, 2);

  rb_define_singleton_method(rb_event, "poll",
    (ruby_method*) &event_poll_impl, 0);

  rb_define_singleton_method(rb_event, "poll_all",
    (ruby_method*) &event_poll_all_impl, 0);
}

} // extern
