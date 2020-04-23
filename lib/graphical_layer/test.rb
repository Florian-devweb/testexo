
# system ("sudo apt-get install libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev")
# system ("gem install ruby2d")
require 'ruby2d'

set title: 'MORPION POO', background: 'aqua' , width: 600, height:600

Image.new(
  'image1.png',
  x: 0, y: 0,
  width: 600, height: 600,
#   color: [1.0, 0.5, 0.2, 1.0],
#   rotate: 90,
  z: 0
)

# Image.new(
#   'round1.png',
#   x: 10, y: 10,
#   width: 200, height: 200,
# #   color: [1.0, 0.5, 0.2, 1.0],
# #   rotate: 90,
#   z: 0
# )

# Image.new(
#   'cross1.png',
#   x: 205, y: 10,
#   width: 200, height: 200,
# #   color: [1.0, 0.5, 0.2, 1.0],
# #   rotate: 90,
#   z: 0
# )


# Image.new(
#   'round1.png',
#   x: 400, y: 10,
#   width: 200, height: 200,
# #   color: [1.0, 0.5, 0.2, 1.0],
# #   rotate: 90,
#   z: 0
# )




# Image.new(
#   'cross1.png',
#   x: 10, y: 205,
#   width: 200, height: 200,
# #   color: [1.0, 0.5, 0.2, 1.0],
# #   rotate: 90,
#   z: 0
# )

# Image.new(
#   'round1.png',
#   x: 205, y: 205,
#   width: 200, height: 200,
# #   color: [1.0, 0.5, 0.2, 1.0],
# #   rotate: 90,
#   z: 0
# )


# Image.new(
#   'cross1.png',
#   x: 400, y: 205,
#   width: 200, height: 200,
# #   color: [1.0, 0.5, 0.2, 1.0],
# #   rotate: 90,
#   z: 0
# )




# Image.new(
#   'round1.png',
#   x: 10, y: 395,
#   width: 200, height: 200,
# #   color: [1.0, 0.5, 0.2, 1.0],
# #   rotate: 90,
#   z: 0
# )

# Image.new(
#   'cross1.png',
#   x: 205, y: 395,
#   width: 200, height: 200,
# #   color: [1.0, 0.5, 0.2, 1.0],
# #   rotate: 90,
#   z: 0
# )


# Image.new(
#   'round1.png',
#   x: 400, y: 395,
#   width: 200, height: 200,
# #   color: [1.0, 0.5, 0.2, 1.0],
# #   rotate: 90,
#   z: 0
# )

# # coin = Sprite.new(
# #   'coin.png',
# #   x: 400, y: 395,
# #   width: 200, height: 200,
# #   clip_width: 84,
# #   time: 300,
# #   loop: true
# #   color: [1, 0.5, 0.2, 1]
# # )



# # coin.play

# @square = Square.new(x: 220, y: 220, z: -1, size: 0, color: 'blue')
# @text=Text.new('NEW GAME',x: 250, y: 0,size: 20,color: 'blue',z: 10)
# @player=Text.new('JOUEUR 1',x: 450, y: 0,size: 20,color: 'blue',z: 10)

# # Define the initial speed (and direction).
# @x_speed = 0
# @y_speed = 0
# i=1

# # Define what happens when a specific key is pressed.
# # Each keypress influences on the  movement along the x and y axis.
# on :key_down do |event|
#   if i==0
#   @square = Square.new(x: 220, y: 220, z: -1, size: 160, color: 'blue')
#   @text.remove
#   @text=Text.new('keyboard',x: 250, y: 0,size: 20,color: 'blue',z: 10)
#   end

#   puts event
#   if event.key == 'left'
#     @x_speed = -2
#     @y_speed = 0
#   elsif event.key == 'right'
#     @x_speed = 2
#     @y_speed = 0
#   elsif event.key == 'up'
#     @x_speed = 0
#     @y_speed = -2
#   elsif event.key == 'down'
#     @x_speed = 0
#     @y_speed = 2
#   elsif event.key == 'space'
#     i+=1
#     @x_speed = 0
#     @y_speed = 0

#   case @square.x 
#   when (0..200)
#     puts 1
#   when (200..400)
#     puts 2
#   when (400..600)
#     puts 3
#   end

#   case @square.y 
#   when (0..200)
#     puts "A"
#   when (200..400)
#     puts "B"
#   when (400..600)
#     puts "C"
#   end
#     if i%2==0
#       @square.remove
#       @square = Square.new(x: 220, y: 220,z: -1, size: 160, color: 'blue')
#       @player.remove
#       @player=Text.new('JOUEUR 2',x: 450, y: 0,size: 20,color: 'fuchsia',z: 10)
#     else
#       @square.remove
#       @square = Square.new(x: 220, y: 220, z: -1, size: 160, color: 'fuchsia')
#       @player.remove
#       @player=Text.new('JOUEUR 1',x: 450, y: 0,size: 20,color: 'blue',z: 10)
#     end

    
#     system("sleep 1")
#   end
# end
# on :mouse_down do |event|
#   # x and y coordinates of the mouse button event
#   puts event.x, event.y

#   # Read the button event
#   case event.button
#   when :left
#     @text.remove
#     @text=Text.new('NEW GAME',x: 250, y: 0,size: 20,color: 'blue',z: 10)
#     i+=1
#     @x_speed = 0
#     @y_speed = 0
#     case event.x 
#     when (0..200)
#       x=30
#     when (200..400)
#       x=220
#     when (400..600)
#       x=412
#     end
  
#     case event.y
#     when (0..200)
#       y=30
#     when (200..400)
#       y=220
#     when (400..600)
#       y=412
#     end
#     if i%2==0
#       @square.remove
#       @square = Square.new(x: x, y: y,z: -1, size: 160, color: 'blue')
#       @player.remove
#       @player=Text.new('JOUEUR 2',x: 450, y: 0,size: 20,color: 'fuchsia',z: 10)
    
#     else
#       @square.remove
#       @square = Square.new(x: x, y: y, z: -1, size: 160, color: 'fuchsia')
#       @player.remove
#       @player=Text.new('JOUEUR 1',x: 450, y: 0,size: 20,color: 'blue',z: 10)
#     end

#     case event.y
#     when (0..200)
#       print "A"
#     when (200..400)
#       print "B"
#     when (400..600)
#       print "C"
#     end  

#     case event.x 
#     when (0..200)
#       print 1
#       puts
#     when (200..400)
#       print 2
#       puts 
#     when (400..600)
#       print 3
#       puts
#     end
  

#   when :middle
#     # Middle mouse button pressed down
#   when :right
#     # Right mouse button pressed down
#   end
# end

# update do
#   @square.x += @x_speed
#   @square.y += @y_speed
  
# end
show
