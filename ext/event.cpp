#include "uridium.h"

#include <SDL2/SDL.h>

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

  VALUE event_resolve(SDL_Event &event, int mask)
  {
    VALUE ruby_event;
    switch (event.type) {
    case SDL_WINDOWEVENT:
      {
        switch (event.window.event) {
        case SDL_WINDOWEVENT_SHOWN:
          LOG("Window %d shown", event.window.windowID);
          break;
        case SDL_WINDOWEVENT_HIDDEN:
          LOG("Window %d hidden", event.window.windowID);
          break;
        case SDL_WINDOWEVENT_EXPOSED:
          LOG("Window %d exposed", event.window.windowID);
          break;
        case SDL_WINDOWEVENT_FOCUS_GAINED:
          {
            LOG("Window %d gained keyboard focus",
                    event.window.windowID);
            //Create an ActivationEvent
              VALUE args[] = {
              Qtrue
            };
              ruby_event = rb_class_new_instance(1, args, rb_activation_event);
              return ruby_event;
              break;
          }
        case SDL_WINDOWEVENT_FOCUS_LOST:
          {
            LOG("Window %d lost keyboard focus",
                    event.window.windowID);
            // Create an ActivationEvent
            VALUE args[] = {
              Qfalse
            };
            ruby_event = rb_class_new_instance(1, args, rb_activation_event);
            return ruby_event;
            break;
          }
        case SDL_WINDOWEVENT_CLOSE:
          LOG("Window %d closed", event.window.windowID);
          break;
        default:
          LOG("Window %d got unknown event %d",
                  event.window.windowID, event.window.event);
          break;
        }
        break;
      }
    case SDL_KEYDOWN:
    case SDL_KEYUP:
      {
        if ((mask & TYPE_KEY) == 0) return Qnil;
        // Create a KeyEvent.
        VALUE args[] = {
          event.key.state == SDL_PRESSED ? Qtrue : Qfalse,
          UINT2NUM(event.key.keysym.scancode)
        };
        ruby_event = rb_class_new_instance(2, args, rb_key_event);
        return ruby_event;
        break;
      }
    default:
      // Unsupported event.
      return Qnil;
    }
    return Qnil;
  }

  int event_mask(int argc, VALUE* argv)
  {
    VALUE rb_mask;
    rb_scan_args(argc, argv, "01", &rb_mask);
    if (!NIL_P(rb_mask))
      {
        return NUM2INT(rb_mask);
      }
    return 0xffffffff;
  }

  VALUE event_poll_impl(int argc, VALUE* argv, VALUE self)
  {
    SDL_Event event;
    unsigned int mask = event_mask(argc, argv);

    if (SDL_PollEvent(&event))
      {
        return event_resolve(event, mask);
      }
    return Qnil;
  }

  VALUE event_poll_all_impl(int argc, VALUE* argv, VALUE self)
  {
    VALUE events = rb_ary_new();
    VALUE ruby_event;
    SDL_Event event;
    unsigned int mask = event_mask(argc, argv);

    while (SDL_PollEvent(&event))
      {
        ruby_event = event_resolve(event, mask);
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
    rb_event = rb_define_class_under(rb_uridium_module, "Event", rb_cObject);
    rb_define_const(rb_event, "TYPE_ACTIVATION", INT2FIX (TYPE_ACTIVATION));
    rb_define_const(rb_event, "TYPE_KEY", INT2FIX (TYPE_KEY));

    rb_activation_event = rb_define_class_under(rb_uridium_module,"ActivationEvent", rb_event);
    rb_define_method(rb_activation_event, "initialize",
                     (ruby_method*) &activation_event_init_impl, 1);

    rb_key_event = rb_define_class_under(rb_uridium_module, "KeyEvent", rb_event);
    rb_define_method(rb_key_event, "initialize",
                     (ruby_method*) &key_event_init_impl, 2);
    rb_define_attr(rb_key_event, "pressed", 1, 0);
    rb_define_attr(rb_key_event, "symbol", 1, 0);

    rb_define_singleton_method(rb_event, "poll",
                               (ruby_method*) &event_poll_impl, -1);

    rb_define_singleton_method(rb_event, "poll_all",
                               (ruby_method*) &event_poll_all_impl, -1);
  }

} // extern
