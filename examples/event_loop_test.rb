$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../ext'))

require 'uridium'
require 'event_loop'
require '../lib/display.rb'

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
    @text = 'Type here: '
    @rotation = 0
    @scale = 1.0
  end
end

logo = Logo.new

# Simulation.
sim = lambda {|t, dt|
  # Update logo attributes.
  puts "sim"
  #logo.text = "Uridium (t: #{sprintf("%1.1f", t)}s, dt: #{sprintf("%1.2f", dt)}s)"
  #logo.rotation += dt * 2
  #logo.scale += dt * 0.1
  return t < 10
}

# Renderer.
renderer = lambda {|sim, alpha|
  # Clear and setup identity transform.
  puts "render"
  gdi.clear
  gdi.trans0
  
  # Apply logo transformation.
  gdi.rotate_z(logo.rotation)
  gdi.scale(logo.scale)

  # Draw logo.
  font.render(logo.text, [10.0, -100.0])
  # gdi.draw_text(font, logo.text)
  gdi.flip
}

activation_handler = lambda {|event|
  puts "Handling activity #{event.inspect}"
}

key_handler = lambda {|event|
  puts "Handling generic key #{event.inspect}"
  logo.text << event.symbol.chr if event.pressed
}

esc_handler = lambda {|event|
  puts "Handling Esc #{event.inspect}"
  exit
}

# Create an event loop with sim dt=0.05s
# (the "simulation" is updated once every 1/20th second)
EventLoop.new(0.2, sim, renderer,
  {
     :key => {
                  27 => esc_handler, 
                  nil => key_handler
                }
  } ).run
# Clean up
Uridium.destroy
