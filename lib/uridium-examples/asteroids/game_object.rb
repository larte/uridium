module Asteroids
  class GameObject
    using Refinements
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

    def step(_game, _t, dt)
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
end
