$LOAD_PATH << '../ext/'
$LOAD_PATH << '../lib/'

require 'uridium'
require 'event_loop'

# Open a display.
Uridium.init
font = Font.new("fonts/goodtimes.ttf", 100)
display = Display.new("Event Loop", 640, 480, false, true)
display.open()
gdi = display.gdi

# Initial color.
text = 'Uridium 000'
frames = 0

# Simulation (uses Ruby 1.9's new lambda syntax).
sim = lambda {|t, dt|
  # Update color with random value.
  text.succ!
  return (frames += 1) < 50
}

# Renderer.
renderer = lambda {|sim|
  gdi.clear
  gdi.scale(1.002)
  gdi.draw_text(font, text)
  gdi.flip
}

# Create an event loop with sim dt=0.1s
# (the "simulation" is updated once every 1/10th second)
EventLoop.new(0.05, sim, renderer).run

# Clean up
Uridium.destroy
