require 'uridium'

Uridium.init
font = Font.new("fonts/base02.ttf", 72)

display = Display.new("High Caliber", 320, 200, false, true)
display.open()
puts "Display size: #{display.size.inspect}"

text = "Y Halo thar!"
puts "Doing some flashy things...Enjoy your epilepsy!"
gdi = display.gdi
20.times do |i|
  gdi.clear(0x00000000)
  # TODO: create gdi.draw_text(font, text)
  font.render(text[0..i+2])
  gdi.rotate_z(2)
  gdi.flip  
  sleep 0.1
end
sleep 2
Uridium.destroy

=begin
font = Font.new("fonts/base02.ttf", 72)
gdi = Gdi.initialize(display)

puts gdi.methods

100.times do
  gdi.clear
  gdi.rotate_z(0.1)
  gdi.draw_text(font, "Halo thar")
  gdi.flip
end
=end

=begin
require 'system'

System.init

display = Display.new("High Caliber", 640, 480, false, 1)
font = Font.new("fonts/base02.ttf", 72)

display.show()
gdi = display.gdi()

100.times do
  gdi.clear()
  gdi.rotate_z(0.1)
  gdi.scale(1.005)
  gdi.draw_text(font, "Hello World!")
  gdi.flip()
end

sleep 1
System.destroy
=end
