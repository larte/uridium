module Asteroids
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

    def step(game, _t, dt)
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

    def render(gdi, _alpha)
      gdi.trans0
      # Render starfield layers.
      @layers.reverse.each_with_index do |layer, i|
        gdi.draw_points_2d(layer.map { |s|
                             [s.x, s.y]}.flatten, 0.7 / (@layers.length - i))
      end
    end
  end
end
