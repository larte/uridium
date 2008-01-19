# 
# gdi.rb
# 
# Created on 10.8.2007, 20:10:18
# 

class Gdi
  
  def initialize(display)
    @display = display
  end

  def flip
    flip_impl
  end

  def draw_text(font, text)
    font.render(self, text)
  end

  inline do |builder|
    builder.add_link_flags('SDL.lib', 'SDLmain.lib', 'OpenGL32.lib')
    builder.include('<SDL.h>')
    builder.include('<gl/gl.h>')

    builder.c('
      void clear()
      {
        glClearColor(0, 0, 0, 0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
      }
    ')

    builder.c('
      void flip()
      {
        SDL_GL_SwapBuffers();
      }
    ')
  
    builder.c('
      void scale(float s)
      {
        glScalef(s, s, s);
      }
    ')
  
    builder.c('
      void rotate_z(float a)
      {
        glRotatef(a, 0, 0, 1);
      }
    ')
  end

end
