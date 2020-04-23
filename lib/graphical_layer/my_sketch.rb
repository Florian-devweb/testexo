def setup
    size 400, 400  
    fill 255
  end
  
  def draw
    background 0
    ellipse mouse_x, mouse_y, 100, 100
  end