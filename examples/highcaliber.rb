$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../ext'))
require '../lib/display.rb'
require 'uridium'

puts $LOAD_PATH

Uridium.init
font = Font.new("fonts/base02.ttf", 72)

display = Display.new("High Caliber", 320, 200, false, false)
display.open()
puts "Display size: #{display.size.inspect}"

text = "Y Halo thar!"
puts "Doing some flashy things...Enjoy your lines!"
gdi = display.gdi
40.times do |i|
  gdi.clear(0x00000000)
  # TODO: create gdi.draw_text(font, text)
  if i < 20
    gdi.draw_line([100+10*i,80+10*i],[150-10*i,80.0], [1.0,0,0])  
    gdi.draw_line([250,320-10*i],[170,i*30.0], [0,1.0,0])  
  else
    font.render(text[0..i-20])
    gdi.rotate_z(5)
  end
  gdi.flip
  sleep 0.1
end
sleep 0.5
Uridium.destroy
