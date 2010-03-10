$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../ext'))

require 'uridium'
require 'event_loop'
require 'mixer'
require 'uridium.rb'

# Timestep, ms.
DT = 20
SCREEN_SIZE         = [640, 480]

class Game
  def initialize
    @level = 1
    Uridium.init
    # Open a display.
    @display = Display.new("Sopwith",
      SCREEN_SIZE[0], SCREEN_SIZE[1], false, true)
    
    @display.open()
    @gdi = @display.gdi

    
    # Init mixer; samplerate, channels, buffer.
    mixer = Mixer.new
    @sounds = {
      :boom => Sound.new("explosion.wav")
    }
  end

  def run
    sim = lambda {|t, dt|
      # Simulate all objects
      return true
    }

    # Renderer.
    renderer = lambda {|sim, alpha|
      # Clear and setup identity transform.
      @gdi.clear
      # Show buffer
      @gdi.flip
    }

    key_left = lambda {|event|

    }

    key_right = lambda {|event|
    }

    key_up = lambda {|event|
    }

    key_space = lambda {|event|
    }

    key_other = lambda {|event|
      if event.symbol == 27

        Uridium.destroy
        exit
      end
    }

    # Run event loop.
    EventLoop.new(DT, sim, renderer,
      {:key => {
          276 => key_left,
          275 => key_right,
          273 => key_up,
          32  => key_space,
          nil => key_other
        }
      }
    ).run
  end

end

Game.new.run
