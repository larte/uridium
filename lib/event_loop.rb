class EventLoop

  def initialize(dt, sim, renderer)
    @dt = dt
    @sim = sim
    @renderer = renderer
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
      
      # TODO: slow the system down by sleeping a little, otherwise
      # the CPU will be burned 100% if the used display isn't synced.
    end  
  end
  
end
