#
# mixer.rb
#
# Created on 16.03.2008 20:05:31
#
module LibUridium
  class Mixer
    # Create a new mixer.
    def initialize(frequency = 44_100, channels = 2, buffer = 2048)
      mixer_init_impl(frequency, channels, buffer)
    end
  end

  class Sound
    # play a sound through the SDL mixer
    def play(samples = 0, channel = -1)
      play_sound_impl(samples, channel)
    end
  end
end
