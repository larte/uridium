require 'uridium'

Uridium.init
display = Display.new("High Caliber", 320, 200, false, true)
display.open()
sleep 5
Uridium.destroy

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