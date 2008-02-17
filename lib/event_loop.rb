class EventLoop

  def initialize(dt, sim, renderer, idle_time = 0.001)
    @dt = dt
    @sim = sim
    @renderer = renderer
    @idle_time = idle_time
  end
  
  def run
    t = 0.0
    accumulator = 0.0
    current_time = Time.now.to_f
    
    # TODO: end conditions
    while true
      # Accumulate time.
      new_time = Time.now.to_f
      delta_time = new_time - current_time
      current_time = new_time
      accumulator += delta_time;
      
      # While accumulated time left, step simulation with fixed dt.
      while accumulator >= @dt
        @sim.call(t, @dt)
        t += @dt
        accumulator -= @dt
      end
      
      # Render the simulation state.
      @renderer.call(@sim)

      # Sleep for idle time.
      sleep(@idle_time)
    end
  end
  
end
