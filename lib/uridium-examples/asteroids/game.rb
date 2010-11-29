require_relative 'settings'
require_relative 'utils'
require_relative 'game_object'
require_relative 'asteroid'
require_relative 'ship'
require_relative 'starfield'
require_relative 'bullet'
require_relative 'ship'

module Asteroids
  class Game
    attr_reader :ship, :asteroids, :bullets,
                :sounds, :level, :lives, :asteroid_speed

    def initialize
      # Init.
      LibUridium::Uridium.init
      @score = 0
      @level = 1
      @lives = LIVES
      # Load a font.
      @info_counter = 0
      @game_over = false

      @asteroid_speed = ASTEROID_SPEED
      @score_font = LibUridium::Font.new(Asteroids.font, 20)
      @lives_font = LibUridium::Font.new(Asteroids.font, 20)
      @info_font = LibUridium::Font.new(Asteroids.font, 40)
      @info_text = nil
      # Open a display.
      @display = LibUridium::Display.new('Asteroids',
                                         SCREEN_SIZE[0],
                                         SCREEN_SIZE[1],
                                         false,
                                         true)

      @display.open
      @gdi = @display.gdi

      @starfield = Starfield.new

      # Init mixer; samplerate, channels, buffer.
      mixer = LibUridium::Mixer.new
      @sounds = {
        laser: LibUridium::Sound.new(Asteroids.laser_sound_path),
        boom: LibUridium::Sound.new(Asteroids.boom_sound_path)
      }
    end

    def end_level
      @ship = nil
      @info_text = 'LEVEL UP!'
      @info_counter = 200
      @level += 1
      @asteroid_speed = (1 + (level / MAX_LEVEL * 1.0)) * @asteroid_speed
      run
    end

    def run
      # Create a ship.
      unless @game_over
        @ship = Ship.new(Vector.new(*@display.size.map { |d| d / 2 }))
        @asteroids = []

        (@level * ASTEROID_COUNT).times do |i|
          @asteroids[i] = Asteroid.new(
            Vector.new(rand(SCREEN_SIZE[0]), rand(SCREEN_SIZE[1])),
            @asteroid_speed
          )
        end
        @bullets = []

      end
      # Simulation.
      sim = lambda { |t, dt|
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
      renderer = lambda { |_sim, alpha|
        # Clear and setup identity transform.
        @gdi.clear
        @score_font.render("Level: #{@level} Score: #{@score}", [10.0, -20.0])
        @lives_font.render('<3 ' * @lives, [SCREEN_SIZE[0] - 140.0, -20.0])
        if @info_text
          @info_font.render(@info_text, [180.0, -(SCREEN_SIZE[1] / 2.0) + 40])
          unless @game_over
            @info_counter -= 1
            @info_text = @info_counter > 0 ? @info_text : nil
          end
        end
        # Render all objects.
        @ship.render(@gdi, alpha) if @ship
        @asteroids.each { |asteroid| asteroid.render(@gdi, alpha) }
        @starfield.render(@gdi, alpha)
        Bullet.render_all(@bullets, @gdi, alpha)

        # Show buffer
        @gdi.flip
      }

      key_left = lambda { |event|
        if @ship
          @ship.av += event.pressed ? -SHIP_ROT_SPEED : SHIP_ROT_SPEED
        end
      }

      key_right = lambda { |event|
        if @ship
          @ship.av += event.pressed ? SHIP_ROT_SPEED : -SHIP_ROT_SPEED
        end
      }

      key_up = lambda { |event|
        @ship.thrusting = event.pressed if @ship
      }

      key_space = lambda { |event|
        @ship.firing = event.pressed if @ship
      }

      key_exit = lambda { |_event|
        LibUridium::Uridium.destroy
        exit
      }

      activation = lambda { |event|
        # noop
      }

      # Run event loop.
      LibUridium::EventLoop.new(DT, sim, renderer,
                                key: {
                                  80 => key_left,
                                  79 => key_right,
                                  82 => key_up,
                                  44 => key_space,
                                  41 => key_exit,
                                  nil => activation
                                },
                                activation: activation).run
    end

    def player_destroyed
      @lives -= 1
      @ship = nil
      @info_text = 'BOOOOOOOM'
      @info_counter = 100
      if @lives == 0
        @info_text = 'GAME OVER'
        @game_over = true
      end
      run
    end

    def update_score(increment)
      @score += increment
    end
  end
end
