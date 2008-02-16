$LOAD_PATH << '../ext/'
$LOAD_PATH << '../lib/'

require 'uridium'
require 'event_loop'

# Open a display.
Uridium.init
display = Display.new("Event Loop", 640, 480, false, true)
display.open()
gdi = display.gdi

# Initial color.
color = 0

# Simulation (uses Ruby 1.9's new lambda syntax).
sim = ->(t, dt){
  # Update color with random value.
  color = rand(0xffffffff)
}

# Renderer.
renderer = -> (sim){
  gdi.clear(color)
  gdi.flip
}

# Create an event loop with sim dt=0.1s
# (the "simulation" is updated once every 1/10th second)
EventLoop.new(0.1, sim, renderer).run

# Clean up
Uridium.destroy
