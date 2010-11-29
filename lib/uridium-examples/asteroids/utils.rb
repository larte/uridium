module Asteroids
  module Refinements
    # Radians->degrees.
    refine Numeric do
      def degrees
        self * 180 / Math::PI
      end
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
      Math.sqrt((@x - v.x)**2 + (@y - v.y)**2)
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
end
