# 
# font.rb
# 
# Created on 10.8.2007, 20:09:19
# 
 

class Font
  
  def initialize(path, size = 12)
    @path = path
    @size = size
    @ftgl_font = initialize_impl(@path, @size)
  end

  def render(gdi, text)
    render_impl(@ftgl_font, text)
  end

  inline do |builder|
    builder.add_compile_flags('/D "FTGL_LIBRARY_STATIC"')
    builder.add_link_flags('freetype235.lib', 'ftgl_static.lib',
      'OpenGL32.lib', 'glu32.lib')
    
    builder.include('<GL/gl.h>')
    builder.include('<GL/glu.h>')
    builder.include('<FTGLTextureFont.h>')
    
    builder.c('
      unsigned int initialize_impl(char* path, int size)
      {
        FTGLTextureFont* font = new FTGLTextureFont(path);
        font->FaceSize(size);
        return (unsigned int) font;
      }
    ')
  
    builder.c('
      void render_impl(unsigned int font, char* text)
      {
        glPushMatrix();
        glEnable(GL_TEXTURE_2D);
	glColor3f(1.0, 1.0, 1.0);
        ((FTFont*) font)->Render(text);
        glPopMatrix();
      }
    ')  
  end
  
end
