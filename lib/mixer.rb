# 
# mixer.rb
# 
# Created on 16.03.2008 20:05:31
# 

class Mixer
  
  def initialize(frequency = 44100, channels = 2, buffer = 2048)
    mixer_init_impl(frequency, channels, buffer)
  end
end

class Sound
  def play(samples = 0, channel = -1)
    play_sound_impl(samples, channel)
  end
end
