require_relative 'game_object'
module Asteroids
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
      gdi.draw_polyline_2d(@vertices.map { |v| [v.x, v.y] }.flatten)
    end
  end
end
