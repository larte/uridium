$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../ext'))

require 'uridium'
require 'event_loop'
require '../lib/uridium.rb'

# Timestep, ms.
DT = 10
SCREEN_SIZE  = [640, 480]
ACCELERATION = 0.0005
ROT_SPEED    = 0.006
DAMPENING    = 0.9995
SAFE_AREA    = 20

# Init.
Uridium.init

# Load a font.
font = Font.new("fonts/goodtimes.ttf", 60)

# Open a display.
display = Display.new("Asteroids", SCREEN_SIZE[0], SCREEN_SIZE[1], false, true)
display.open()
gdi = display.gdi

# Radians->degrees.
class Numeric
  def degrees
    self * 180 / Math::PI
  end
end

class Vector
  attr_accessor :x, :y
  
  def initialize(x = 0, y = 0)
    set(x, y)
  end

  def set(x, y)
    @x = x
    @y = y
  end
  
  def zero
    @x = 0
    @y = 0
  end
  
  def +(v)
    Vector.new(@x + v.x, @y + v.y)
  end
  
  def *(v)
    Vector.new(@x * v, @y * v)
  end
end

class GameObject
  # Position, velocity, acceleration, rotation, angular velocity.
  attr_accessor :p, :v, :a, :r, :av
  
  def initialize(x, y)
    # Init sim properties.
    @p = Vector.new(x, y)
    @v = Vector.new
    @a = Vector.new
    @r = 0
    @av = 0
    
    # Step velocity and angular velocity (used for interpolation).
    @sv = Vector.new
    @sav = 0
  end  
  
  def step(dt)
    @v += @a * dt
    @sv = @v * dt
    @p += @sv
    @sav = @av * dt
    @r += @sav
    
    # Limit to screen bounds (TODO: safe area).
    @p.x %= SCREEN_SIZE[0]
    @p.y %= SCREEN_SIZE[1]
  end
  
  def render(gdi, alpha)
    gdi.translate(@p.x - @sv.x * alpha, @p.y - @sv.y * alpha)
    gdi.rotate_z(@r.degrees - @sav.degrees * alpha)
  end
end

class Ship < GameObject
  attr_accessor :thrust, :fire
  
  def step(dt)
    # Set accelaration.
    if @thrust
      @a.set(
        Math.sin(@r) * ACCELERATION,
        -Math.cos(@r) * ACCELERATION
      )
    else
      @a.zero
    end

    super
    
    # Dampen velocity.
    @v *= DAMPENING ** dt
  end
  
  def render(gdi, alpha)
    super
    gdi.draw_polyline_2d([
      0.0, -13.0,
      10.0, 10.0,
      0.0, 5.0,
      -10.0, 10.0,
      0.0, -13.0
    ])
  end
end

# Create a ship.
ship = Ship.new(*display.size.map {|d| d / 2})
objects = [ship]

# Init mixer; samplerate, channels, buffer.
mixer = Mixer.new(44100, 2, 1024)

# Simulation.
sim = lambda {|t, dt|
  # Simulate all objects
  objects.each  do |object|
    object.step(dt)
  end
  return true
}

# Renderer.
renderer = lambda {|sim, alpha|
  #puts alpha

  # Clear and setup identity transform.
  gdi.clear
  gdi.trans0

  ship.render(gdi, alpha)
 
  gdi.flip
}

key_left = lambda {|event|
  ship.av = event.pressed ? -ROT_SPEED : 0
}

key_right = lambda {|event|
  ship.av = event.pressed ? ROT_SPEED : 0
}

key_up = lambda {|event|
  ship.thrust = event.pressed
}

key_space = lambda {|event|
  mixer.play_sound("laser.wav")
  ship.fire = event.pressed
}

key_other = lambda {|event|
  if event.symbol == 27
     # Clean up and exit.
     Uridium.destroy
     exit
  end  
}

# Run event loop.
EventLoop.new(DT, sim, renderer,
  {:key => {
      276 => key_left,
      275 => key_right,
      273 => key_up,
      32  => key_space,
      nil => key_other
    }
  }
).run
