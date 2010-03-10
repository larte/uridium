$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../ext'))

require 'uridium'
require 'event_loop'
require 'mixer'
require 'uridium.rb'

# Timestep, ms.
DT = 20
SCREEN_SIZE         = [640, 480]
SHIP_ACCEL          = 0.0005
SHIP_ROT_SPEED      = 0.006
SHIP_VEL_DAMP       = 0.9995
SHIP_FIRING_DELAY   = 200
ASTEROID_COUNT      = 2 #5
ASTEROID_SPEED      = 0.1
ASTEROID_ROT_SPEED  = 0.005
ASTEROID_VERTICES   = 20
ASTEROID_RADIUS     = 40
ASTEROID_ROUGHNESS  = 0.4
BULLET_SPEED        = 0.4
BULLET_LIFETIME     = 1100
SAFE_AREA           = 20
MAX_LEVEL = 9
LIVES = 3

# Radians->degrees.
class Numeric
  def degrees
    self * 180 / Math::PI
  end
end

class Vector
  attr_accessor :x, :y
  
  def initialize(x = 0, y = 0)
    @x = x
    @y = y
  end
  
  def zero
    @x = 0
    @y = 0
  end
  
  def distance(v)
    Math.sqrt((@x - v.x) ** 2 + (@y - v.y) ** 2)
  end
  
  def +(v)
    Vector.new(@x + v.x, @y + v.y)
  end

  def -(v)
    Vector.new(@x - v.x, @y - v.y)
  end
  
  def *(v)
    Vector.new(@x * v, @y * v)
  end
  
  def self.direction(angle)
    Vector.new(Math.sin(angle), -Math.cos(angle))
  end
end

class GameObject
  # Position, velocity, acceleration, rotation, angular velocity.
  attr_accessor :p, :v, :a, :r, :av
  
  def initialize(p, v = Vector.new, av = 0)
    # Init sim properties.
    @p = p
    @v = v
    @a = Vector.new
    @r = 0
    @av = av
    
    # Step velocity and angular velocity (used for interpolation).
    @sv = Vector.new
    @sav = 0
  end  
  
  def direction
    Vector.direction(@r)
  end
  
  def step(game, t, dt)
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
    gdi.trans0
    gdi.translate(@p.x - @sv.x * alpha, @p.y - @sv.y * alpha)
    gdi.rotate_z(@r.degrees - @sav.degrees * alpha)
  end
end

class Ship < GameObject
  attr_accessor :thrusting, :firing
  
  def initialize(p)
    super
    @last_fired = nil
  end
  
  def step(game, t, dt)
    d = direction
    
    # Accelaration.
    @a = @thrusting ? d * SHIP_ACCEL : Vector.new

    # Fire bullets.
    if @firing && (!@last_fired || t - @last_fired > SHIP_FIRING_DELAY)
      game.sounds[:laser].play
      game.bullets << Bullet.new(@p, @v + d * BULLET_SPEED, t)
      @last_fired = t
    end

    
    super
    
    # Collide with asteroids.
    game.asteroids.each do |asteroid|
      if @p.distance(asteroid.p) < asteroid.radius
        # 
        game.asteroids.delete(asteroid)
        game.sounds[:boom].play
        game.update_score(-1000)
        if asteroid.radius > ASTEROID_RADIUS / 2.5
          3.times do
            game.asteroids << Asteroid.new(asteroid.p, asteroid.radius / 2)
          end
        end  
        game.player_destroyed
        break
      end
    end


    # Dampen velocity.
    @v *= SHIP_VEL_DAMP ** dt
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

class Asteroid < GameObject
  attr_reader :radius
  
  def initialize(p, speed, radius = ASTEROID_RADIUS)
    super
    
    @radius = radius
    @v = Vector.new(
      (rand(speed * 1000) - speed * 500) / 1000.0,
      (rand(speed * 1000) - speed * 500) / 1000.0
    )
    @av = (rand(ASTEROID_ROT_SPEED * 1000) - ASTEROID_ROT_SPEED * 500) / 1000.0
    
    @vertices = []
    step = Math::PI * 2 / ASTEROID_VERTICES
    angle = 0
    ASTEROID_VERTICES.times do
      @vertices << Vector.direction(angle) *
        (@radius - @radius * (rand(ASTEROID_ROUGHNESS * 1000) / 1000.0))
      angle += step
    end
    @vertices << @vertices.first
  end

  def step(game, t, dt)
    super
  end
  
  def render(gdi, alpha)
    super
    gdi.draw_polyline_2d(@vertices.map{|v| [v.x, v.y]}.flatten)
  end
  
end
  
class Bullet < GameObject
  def initialize(p, v, t)
    super(p, v)
    @created = t
  end

  def step(game, t, dt)
    super
    
    # Collide with asteroids.
    game.asteroids.each do |asteroid|
      if @p.distance(asteroid.p) < asteroid.radius
        # Bam.
        game.sounds[:boom].play
        game.asteroids.delete(asteroid)
        game.bullets.delete(self)
        points = (50 - asteroid.radius)
        game.update_score(points)
        if asteroid.radius > ASTEROID_RADIUS / 2.5
          3.times do
            game.asteroids << Asteroid.new(asteroid.p, game.asteroid_speed, asteroid.radius / 2)
          end
        elsif game.asteroids.empty?
          game.end_level
          break
        end
        break
      end
    end
    
    # Remove expired bullets.
    game.bullets.delete(self) if t - @created > BULLET_LIFETIME
  end
    
  def self.render_all(bullets, gdi, alpha)
    # Render all bullets with a single sweep.
    gdi.trans0
    gdi.draw_points_2d(bullets.map {|b| [b.p.x, b.p.y]}.flatten, 1)
  end  
end

class Starfield
  def initialize
    @layers = []
    3.times do
      stars = []
      150.times do
        stars << Vector.new(rand(SCREEN_SIZE[0]), rand(SCREEN_SIZE[1]))
      end
      @layers << stars
    end
  end
  
  def step(game, t, dt)
    # Move the starfield in parallax style.
    if game.ship
      @layers.each_with_index do |layer, i|
        layer.each do |star|
          star.x = (star.x - game.ship.v.x * (0.5 / (i + 1)) * dt) % SCREEN_SIZE[0]
          star.y = (star.y - game.ship.v.y * (0.5 / (i + 1)) * dt) % SCREEN_SIZE[1]
        end
      end
    end
  end
  
  def render(gdi, alpha)
    gdi.trans0
    # Render starfield layers.
    @layers.reverse.each_with_index do |layer, i|
      gdi.draw_points_2d(layer.map {|s|
        [s.x, s.y]}.flatten, 0.7 / (@layers.length - i))
    end  
  end
end

class Game

  attr_reader :ship, :asteroids, :bullets, :sounds, :level, :lives, :asteroid_speed



  def initialize
    # Init.
    Uridium.init
    @score = 0
    @level = 1
    @lives = LIVES
    # Load a font.
    @info_counter = 0
    @game_over = false

    @asteroid_speed = ASTEROID_SPEED
    @score_font = Font.new("fonts/goodtimes.ttf", 20)
    @lives_font = Font.new("fonts/goodtimes.ttf", 20)
    @info_font = Font.new("fonts/goodtimes.ttf", 40)
    @info_text = nil
    # Open a display.
    @display = Display.new("Asteroids",
      SCREEN_SIZE[0], SCREEN_SIZE[1], false, true)
    
    @display.open()
    @gdi = @display.gdi

    @starfield = Starfield.new

    
    # Init mixer; samplerate, channels, buffer.
    mixer = Mixer.new
    @sounds = {
      :laser => Sound.new("laser.wav"),
      :boom => Sound.new("explosion.wav")
    }

  end

  def end_level
    @ship = nil
    @info_text = "LEVEL UP!"
    @info_counter = 200
    @level += 1
    @asteroid_speed = (1+(level/MAX_LEVEL*1.0))*@asteroid_speed
    run
  end

  def run
    # Create a ship.
    if !@game_over
      @ship = Ship.new(Vector.new(*@display.size.map {|d| d / 2}))
      @asteroids = []


      (@level*ASTEROID_COUNT).times do |i| 
        @asteroids[i] = Asteroid.new(
                     Vector.new(rand(SCREEN_SIZE[0]), rand(SCREEN_SIZE[1])), 
                                     @asteroid_speed)
      end
      @bullets = []

    end
    # Simulation.
    sim = lambda {|t, dt|
      # Simulate all objects
      @ship.step(self, t, dt) if @ship
      @asteroids.each do |asteroid|
        asteroid.step(self, t, dt)
      end
      @starfield.step(self, t, dt)
      @bullets.each do |bullet|
        bullet.step(self, t, dt)
      end
      return true
    }

    # Renderer.
    renderer = lambda {|sim, alpha|
      # Clear and setup identity transform.
      @gdi.clear
      @score_font.render("Level: #{@level} Score: #{@score}", [10.0, -20.0])
      @lives_font.render("<3 "*@lives, [SCREEN_SIZE[0]-140.0 , -20.0])
      if @info_text
        @info_font.render(@info_text, [180.0, -(SCREEN_SIZE[1]/2.0) + 40]) 
        if !@game_over
          @info_counter -= 1
          @info_text = (@info_counter > 0) ? @info_text : nil
        end
      end
      # Render all objects.
      @ship.render(@gdi, alpha) if @ship
      @asteroids.each {|asteroid| asteroid.render(@gdi, alpha)}
      @starfield.render(@gdi, alpha)
      Bullet.render_all(@bullets, @gdi, alpha)

      # Show buffer
      @gdi.flip
    }

    key_left = lambda {|event|
      if @ship
        @ship.av += event.pressed ? -SHIP_ROT_SPEED : SHIP_ROT_SPEED
      end
    }

    key_right = lambda {|event|
      if @ship
        @ship.av += event.pressed ? SHIP_ROT_SPEED : -SHIP_ROT_SPEED 
      end
    }

    key_up = lambda {|event|
      @ship.thrusting = event.pressed if @ship
    }

    key_space = lambda {|event|
      @ship.firing = event.pressed if @ship
    }

    key_other = lambda {|event|
      if event.symbol == 27

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
  end
  
  def player_destroyed
    @lives -= 1
    @ship = nil
    @info_text = "BOOOOOOOM"
    @info_counter = 100
    if @lives == 0
      @info_text = "GAME OVER"
      @game_over = true
    end
    run
  end

  def update_score(increment)
    @score += increment
  end

end

# Run the game.
Game.new.run

