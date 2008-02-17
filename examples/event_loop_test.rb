$LOAD_PATH << '../ext/'
$LOAD_PATH << '../lib/'

require 'uridium'
require 'event_loop'

# Init.
Uridium.init

# Load a font.
font = Font.new("fonts/goodtimes.ttf", 60)

# Open a display.
display = Display.new("Event Loop", 640, 480, false, true)
display.open()
gdi = display.gdi

# Create a simple actor.
class Logo
  attr_accessor :text, :rotation, :scale
  
  def initialize
    @text = ''
    @rotation = 0
    @scale = 1.0
  end
end

logo = Logo.new

# Simulation.
sim = lambda {|t, dt|
  # Update logo attributes.
  logo.text = "Uridium (t: #{sprintf("%1.1f", t)}s, dt: #{sprintf("%1.2f", dt)}s)"
  logo.rotation += dt * 2
  logo.scale += dt * 0.1
  return t < 10
}

# Renderer.
renderer = lambda {|sim|
  # Clear and setup identity transform.
  gdi.clear
  gdi.trans0
  
  # Apply logo transformation.
  gdi.rotate_z(logo.rotation)
  gdi.scale(logo.scale)

  # Draw logo.
  gdi.draw_text(font, logo.text)
  gdi.flip
}

# Create an event loop with sim dt=0.05s
# (the "simulation" is updated once every 1/20th second)
EventLoop.new(0.05, sim, renderer).run

# Clean up
Uridium.destroy
