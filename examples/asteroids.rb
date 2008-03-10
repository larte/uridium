$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../ext'))

require 'uridium'
require 'event_loop'
require '../lib/uridium.rb'

EVENT_LOOP_FPS = 100

# Radians->degrees.
class Numeric
  def degrees
    self * 180 / Math::PI
  end
end

# Init.
Uridium.init

# Load a font.
font = Font.new("fonts/goodtimes.ttf", 60)

# Open a display.
display = Display.new("Asteroids", 640, 480, false, true)
display.open()
gdi = display.gdi

class Ship
  attr_accessor :angle, :steer, :thrust, :fire
  
  def initialize(x, y)
    @x = x
    @y = y
    @vx = 0
    @vy = 0
    @angle = 0
    @steer = 0
    @thrust = 0
    @fire = false
    @fire_delay = 0
    @bullets = []
  end

  def step(dt)
    @angle += @steer * 5 * dt
    @vx += Math.sin(@angle) * @thrust * 300 * dt
    @vy += -Math.cos(@angle) * @thrust * 300 * dt
    @x += @vx * dt
    @y += @vy * dt

    # Dampen velocity a bit.
    @vx *= 0.7**dt
    @vy *= 0.7**dt

    if @fire && @fire_delay <= 0
      vx = Math.sin(@angle) * 200
      vy = -Math.cos(@angle) * 200
      @bullets << [@x + vx * 0.05, @y + vy * 0.05, @vx + vx, @vy + vy]
      @fire_delay = 0.1
    else
      @fire_delay -= dt
    end
    
    @bullets.each do |bullet|
      bullet[0] += bullet[2] * dt
      bullet[1] += bullet[3] * dt
    end
  end
  
  def render(gdi)
    @bullets.each do |bullet|
      gdi.draw_points_2d([
        bullet[0], bullet[1],
        bullet[0] + 1, bullet[1] + 1
      ])
    end

    gdi.translate(@x, @y)
    gdi.rotate_z(@angle.degrees)
    gdi.draw_polyline_2d([
      0.0, -13.0,
      10.0, 10.0,
      0.0, 5.0,
      -10.0, 10.0,
      0.0, -13.0
    ])
  end
end

ship = Ship.new(*display.size.map {|d| d / 2})
# samplerate, channels, buffer.
mixer = Mixer.new(44100, 2, 1024)
# Simulation.
sim = lambda {|t, dt|
  ship.step(dt)
  return true
}

# Renderer.
renderer = lambda {|sim|
  # Clear and setup identity transform.
  gdi.clear
  gdi.trans0

  ship.render(gdi)
 
  gdi.flip
}

key_left = lambda {|event|
  ship.steer = event.pressed ? -1 : 0
}

key_right = lambda {|event|
  ship.steer = event.pressed ? 1 : 0
}

key_up = lambda {|event|
  ship.thrust = event.pressed ? 1 : 0
}

key_space = lambda {|event|
  mixer.play_sound("laser.wav")
  ship.fire = event.pressed
}

key_other = lambda {|event|
  puts event.symbol
  if event.symbol == 27
     Uridium.destroy
     exit
  end  
}

# Run event loop.
EventLoop.new(1.0 / EVENT_LOOP_FPS, sim, renderer,
  {:key => {
      276 => key_left,
      275 => key_right,
      273 => key_up,
      32  => key_space,
      nil => key_other
    }
  }
).run

# Clean up.
Uridium.destroy
