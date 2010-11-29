require_relative 'utils'
module Asteroids
  class Ship < GameObject
    attr_accessor :thrusting, :firing
    using Refinements

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
        next unless @p.distance(asteroid.p) < asteroid.radius
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

      # Dampen velocity.
      @v *= SHIP_VEL_DAMP**dt
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
end
