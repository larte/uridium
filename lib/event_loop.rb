class EventLoop

  def initialize(dt, sim, renderer, event_handlers = {}, idle_time = 10)
    @dt = dt
    @sim = sim
    @renderer = renderer
    @idle_time = idle_time
    @event_handlers = event_handlers
    @event_mask = event_mask(event_handlers)
  end
  
  def event_mask(event_handlers)
    mask = 0
    mask |= Event::TYPE_KEY if event_handlers[:key]
    mask |= Event::TYPE_ACTIVATION if event_handlers[:activation]
    return mask
  end
  
  def dispatch_event(event)
    case event
      when ActivationEvent
        @event_handlers[:activation].call(event)
      when KeyEvent
        handler = @event_handlers[:key]
        if handler.is_a?(Proc)  
          handler.call(event) 
        else
          handler = handler[event.symbol] || handler[nil]
          handler.call(event) if handler
        end
      else
        raise "Unsupported event type: #{event.class.name}"
    end
  end
  
  def run
    t = 0
    accumulator = 0
    current_time = Clock.ticks
    
    while true
      # Accumulate time.
      new_time = Clock.ticks
      delta_time = new_time - current_time
      current_time = new_time
      accumulator += delta_time;
      # While accumulated time left, step simulation with fixed dt.
      while accumulator >= @dt
        # Poll and dispatch events.
        if @event_mask != 0
          events = Event.poll_all(@event_mask)
          events.each {|event| dispatch_event(event)}
        end
        return unless @sim.call(t, @dt)

        # Step in time.
        t += @dt
        accumulator -= @dt
      end
      
      # Render the simulation state with interpolation value alpha.
      alpha = 1 - accumulator.to_f / @dt;
      @renderer.call(@sim, alpha)

      # Sleep for idle time.
      Clock.sleep(@idle_time)
    end
  end
  
end
