# system ("sudo apt-get install libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev")
# system ("gem install ruby2d")

set title: 'MORPION POO', background: 'aqua' , width: 600, height:600

# Define a square shape.
# Square.new(
#   x: 0, y: 0,
#   size: 200,
#   color: 'white',
#   z: 10
# )
# Square.new(
#   x: 0, y: 200,
#   size: 200,
#   color: 'gray',
#   z: 10
# )
# Square.new(
#   x: 0, y: 400,
#   size: 200,
#   color: 'white',
#   z: 10
# )


# Square.new(
#   x: 200, y: 0,
#   size: 200,
#   color: 'gray',
#   z: 10
# )
# Square.new(
#   x: 200, y: 200,
#   size: 200,
#   color: 'white',
#   z: 10
# )
# Square.new(
#   x: 200, y: 400,
#   size: 200,
#   color: 'gray',
#   z: 10
# )


# Square.new(
#   x: 400, y: 0,
#   size: 200,
#   color: 'white',
#   z: 10
# )
# Square.new(
#   x: 400, y: 200,
#   size: 200,
#   color: 'gray',
#   z: 10
# )
# Square.new(
#   x: 400, y: 400,
#   size: 200,
#   color: 'white',
#   z: 10
# )
Image.new(
  'image1.png',
  x: 0, y: 0,
  width: 600, height: 600,
#   color: [1.0, 0.5, 0.2, 1.0],
#   rotate: 90,
  z: 0
)

Image.new(
  'round1.png',
  x: 10, y: 10,
  width: 200, height: 200,
#   color: [1.0, 0.5, 0.2, 1.0],
#   rotate: 90,
  z: 0
)

Image.new(
  'cross1.png',
  x: 205, y: 10,
  width: 200, height: 200,
#   color: [1.0, 0.5, 0.2, 1.0],
#   rotate: 90,
  z: 0
)


Image.new(
  'round1.png',
  x: 400, y: 10,
  width: 200, height: 200,
#   color: [1.0, 0.5, 0.2, 1.0],
#   rotate: 90,
  z: 0
)




Image.new(
  'cross1.png',
  x: 10, y: 205,
  width: 200, height: 200,
#   color: [1.0, 0.5, 0.2, 1.0],
#   rotate: 90,
  z: 0
)

Image.new(
  'round1.png',
  x: 205, y: 205,
  width: 200, height: 200,
#   color: [1.0, 0.5, 0.2, 1.0],
#   rotate: 90,
  z: 0
)


Image.new(
  'cross1.png',
  x: 400, y: 205,
  width: 200, height: 200,
#   color: [1.0, 0.5, 0.2, 1.0],
#   rotate: 90,
  z: 0
)




Image.new(
  'round1.png',
  x: 10, y: 395,
  width: 200, height: 200,
#   color: [1.0, 0.5, 0.2, 1.0],
#   rotate: 90,
  z: 0
)

Image.new(
  'cross1.png',
  x: 205, y: 395,
  width: 200, height: 200,
#   color: [1.0, 0.5, 0.2, 1.0],
#   rotate: 90,
  z: 0
)


Image.new(
  'round1.png',
  x: 400, y: 395,
  width: 200, height: 200,
#   color: [1.0, 0.5, 0.2, 1.0],
#   rotate: 90,
  z: 0
)


show