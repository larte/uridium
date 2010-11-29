module Asteroids
  DT = 20
  SCREEN_SIZE         = [1024, 780].freeze
  SHIP_ACCEL          = 0.0005
  SHIP_ROT_SPEED      = 0.006
  SHIP_VEL_DAMP       = 0.9995
  SHIP_FIRING_DELAY   = 200
  ASTEROID_COUNT      = 2 # 5
  ASTEROID_SPEED      = 0.1
  ASTEROID_ROT_SPEED  = 0.005
  ASTEROID_VERTICES   = 20
  ASTEROID_RADIUS     = 40
  ASTEROID_ROUGHNESS  = 0.4
  BULLET_SPEED        = 0.4
  BULLET_LIFETIME     = 1100
  SAFE_AREA           = 20
  MAX_LEVEL           = 9
  LIVES               = 3

  def self.font
    File.join(File.dirname(__FILE__), 'data', 'goodtimes.ttf')
  end

  def self.laser_sound_path
    File.join(File.dirname(__FILE__), 'data', 'laser.wav')
  end

  def self.boom_sound_path
    File.join(File.dirname(__FILE__), 'data', 'explosion.wav')
  end
end
