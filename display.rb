# 
# display.rb
# 
# Created on 2.8.2007, 21:50:30
# 

class Display

  def initialize(name, width, height, fullscreen, sync)
    @name = name
    @width = width
    @height = height
    @fullscreen = fullscreen
    @sync = sync
  end

  def open()
    open_impl(@name, @width, @height, @fullscreen ? 1 : 0)
    sync_impl(@sync ? 1 : 0)
    puts "sdl_surface: #{@sdl_surface.inspect}"
  end
  
  def gdi
    Gdi.new(self)
  end

end

