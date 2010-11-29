module Asteroids
  class Bullet < GameObject
    def initialize(p, v, t)
      super(p, v)
      @created = t
    end

    def step(game, t, dt)
      super

      # Collide with asteroids.
      game.asteroids.each do |asteroid|
        next unless @p.distance(asteroid.p) < asteroid.radius
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

      # Remove expired bullets.
      game.bullets.delete(self) if t - @created > BULLET_LIFETIME
    end

    def self.render_all(bullets, gdi, _alpha)
      # Render all bullets with a single sweep.
      gdi.trans0
      gdi.draw_points_2d(bullets.map { |b| [b.p.x, b.p.y] }.flatten, 1)
    end
  end
end
