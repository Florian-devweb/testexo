# String#ruby2d_colorize

# Extend `String` to include some fancy colors
class String
  def ruby2d_colorize(c); "\e[#{c}m#{self}\e[0m" end
  def bold;  ruby2d_colorize('1')    end
  def info;  ruby2d_colorize('1;34') end
  def warn;  ruby2d_colorize('1;33') end
  def error; ruby2d_colorize('1;31') end
end


# Ruby2D::Error

module Ruby2D
  class Error < StandardError
  end
end


# Ruby2D::Renderable

module Ruby2D
  module Renderable

    attr_reader :x, :y, :z, :width, :height, :color

    # Set the z position (depth) of the object
    def z=(z)
      remove
      @z = z
      add
    end

    # Add the object to the window
    def add
      if Module.const_defined? :DSL
        Window.add(self)
      end
    end

    # Remove the object from the window
    def remove
      if Module.const_defined? :DSL
        Window.remove(self)
      end
    end

    # Set the color value
    def color=(c)
      @color = Color.new(c)
    end

    # Allow British English spelling of color
    def colour; self.color end
    def colour=(c); self.color = c end

    # Allow shortcuts for setting color values
    def r; self.color.r end
    def g; self.color.g end
    def b; self.color.b end
    def a; self.color.a end
    def r=(c); self.color.r = c end
    def g=(c); self.color.g = c end
    def b=(c); self.color.b = c end
    def a=(c); self.color.a = c end
    def opacity; self.color.opacity end
    def opacity=(val); self.color.opacity = val end

    # Add a contains method stub
    def contains?(x, y)
      x >= @x && x <= (@x + @width) && y >= @y && y <= (@y + @height)
    end

  end
end


# Ruby2D::Color

module Ruby2D
  class Color

    # Color::Set represents an array of colors
    class Set
      def initialize(colors)
        @colors = colors.map { |c| Color.new(c) }
      end

      def [](i)
        @colors[i]
      end

      def length
        @colors.length
      end

      def opacity; @colors[0].opacity end

      def opacity=(opacity)
        @colors.each do |color|
          color.opacity = opacity
        end
      end
    end

    attr_accessor :r, :g, :b, :a

    # Based on clrs.cc
    @@colors = {
      'navy'    => '#001F3F',
      'blue'    => '#0074D9',
      'aqua'    => '#7FDBFF',
      'teal'    => '#39CCCC',
      'olive'   => '#3D9970',
      'green'   => '#2ECC40',
      'lime'    => '#01FF70',
      'yellow'  => '#FFDC00',
      'orange'  => '#FF851B',
      'red'     => '#FF4136',
      'brown'   => '#663300',
      'fuchsia' => '#F012BE',
      'purple'  => '#B10DC9',
      'maroon'  => '#85144B',
      'white'   => '#FFFFFF',
      'silver'  => '#DDDDDD',
      'gray'    => '#AAAAAA',
      'black'   => '#111111',
      'random'  => ''
    }

    def initialize(c)
      if !self.class.is_valid? c
        raise Error, "`#{c}` is not a valid color"
      else
        case c
        when String
          if c == 'random'
            @r, @g, @b, @a = rand, rand, rand, 1.0
          elsif self.class.is_hex?(c)
            @r, @g, @b, @a = hex_to_f(c)
          else
            @r, @g, @b, @a = hex_to_f(@@colors[c])
          end
        when Array
          @r, @g, @b, @a = [c[0], c[1], c[2], c[3]]
        when Color
          @r, @g, @b, @a = [c.r, c.g, c.b, c.a]
        end
      end
    end

    # Return a color set if an array of valid colors
    def self.set(colors)
      # If a valid array of colors, return a `Color::Set` with those colors
      if colors.is_a?(Array) && colors.all? { |el| Color.is_valid? el }
        Color::Set.new(colors)
      # Otherwise, return single color
      else
        Color.new(colors)
      end
    end

    # Check if string is a proper hex value
    def self.is_hex?(s)
      # MRuby doesn't support regex, otherwise we'd do:
      #   !(/^#[0-9A-F]{6}$/i.match(a).nil?)
      s.class == String && s[0] == '#' && s.length == 7
    end

    # Check if the color is valid
    def self.is_valid?(c)
      c.is_a?(Color)   ||  # color object
      @@colors.key?(c) ||  # keyword
      self.is_hex?(c)  ||  # hexadecimal value

      # Array of Floats from 0.0..1.0
      c.class == Array && c.length == 4 &&
      c.all? { |el| el.is_a?(Numeric) }
    end

    # Convenience methods to alias `opacity` to `@a`
    def opacity; @a end
    def opacity=(opacity); @a = opacity end

    private

    # Convert from Fixnum (0..255) to Float (0.0..1.0)
    def to_f(a)
      b = []
      a.each do |n|
        b.push(n / 255.0)
      end
      return b
    end

    # Convert from hex value (e.g. #FFF000) to Float (0.0..1.0)
    def hex_to_f(h)
      h = (h[1..-1]).chars.each_slice(2).map(&:join)
      a = []

      h.each do |el|
        a.push(el.to_i(16))
      end

      a.push(255)
      return to_f(a)
    end

  end

  # Allow British English spelling of color
  Colour = Color
end


# Ruby2D::Window
# Represents a window on screen, responsible for storing renderable graphics,
# event handlers, the update loop, showing and closing the window.

module Ruby2D
  class Window

    # Event structures
    EventDescriptor = Struct.new(:type, :id)
    MouseEvent = Struct.new(:type, :button, :direction, :x, :y, :delta_x, :delta_y)
    KeyEvent   = Struct.new(:type, :key)
    ControllerEvent       = Struct.new(:which, :type, :axis, :value, :button)
    ControllerAxisEvent   = Struct.new(:which, :axis, :value)
    ControllerButtonEvent = Struct.new(:which, :button)

    def initialize(args = {})

      # This window instance, stored so it can be called by the class methods
      @@window = self

      # Title of the window
      @title = args[:title]  || "Ruby 2D"

      # Window background color
      @background = Color.new([0.0, 0.0, 0.0, 1.0])

      # Window icon
      @icon = nil

      # Window size and characteristics
      @width  = args[:width]  || 640
      @height = args[:height] || 480
      @resizable = false
      @borderless = false
      @fullscreen = false
      @highdpi = false

      # Size of the window's viewport (the drawable area)
      @viewport_width, @viewport_height = nil, nil

      # Size of the computer's display
      @display_width, @display_height = nil, nil

      # Total number of frames that have been rendered
      @frames = 0

      # Frames per second upper limit, and the actual FPS
      @fps_cap = args[:fps_cap] || 60
      @fps = @fps_cap

      # Vertical synchronization, set to prevent screen tearing (recommended)
      @vsync = args[:vsync] || true

      # Mouse X and Y position in the window
      @mouse_x, @mouse_y = 0, 0

      # Controller axis and button mappings file
      @controller_mappings = File.expand_path('~') + "/.ruby2d/controllers.txt"

      # Renderable objects currently in the window, like a linear scene graph
      @objects = []

      # Unique ID for the input event being registered
      @event_key = 0

      # Registered input events
      @events = {
        key: {},
        key_down: {},
        key_held: {},
        key_up: {},
        mouse: {},
        mouse_up: {},
        mouse_down: {},
        mouse_scroll: {},
        mouse_move: {},
        controller: {},
        controller_axis: {},
        controller_button_down: {},
        controller_button_up: {}
      }

      # The window update block
      @update_proc = Proc.new {}

      # Whether diagnostic messages should be printed
      @diagnostics = false

      # Console mode, enabled at command line
      if RUBY_ENGINE == 'ruby'
        @console = defined?($ruby2d_console_mode) ? true : false
      else
        @console = false
      end
    end

    # Class methods for convenient access to properties
    class << self
      def current;         get(:window)          end
      def title;           get(:title)           end
      def background;      get(:background)      end
      def width;           get(:width)           end
      def height;          get(:height)          end
      def viewport_width;  get(:viewport_width)  end
      def viewport_height; get(:viewport_height) end
      def display_width;   get(:display_width)   end
      def display_height;  get(:display_height)  end
      def resizable;       get(:resizable)       end
      def borderless;      get(:borderless)      end
      def fullscreen;      get(:fullscreen)      end
      def highdpi;         get(:highdpi)         end
      def frames;          get(:frames)          end
      def fps;             get(:fps)             end
      def fps_cap;         get(:fps_cap)         end
      def mouse_x;         get(:mouse_x)         end
      def mouse_y;         get(:mouse_y)         end
      def diagnostics;     get(:diagnostics)     end
      def screenshot(opts = nil); get(:screenshot, opts) end

      def get(sym, opts = nil)
        @@window.get(sym, opts)
      end

      def set(opts)
        @@window.set(opts)
      end

      def on(event, &proc)
        @@window.on(event, &proc)
      end

      def off(event_descriptor)
        @@window.off(event_descriptor)
      end

      def add(o)
        @@window.add(o)
      end

      def remove(o)
        @@window.remove(o)
      end

      def clear
        @@window.clear
      end

      def update(&proc)
        @@window.update(&proc)
      end

      def show
        @@window.show
      end

      def close
        @@window.close
      end
    end

    # Public instance methods

    # Retrieve an attribute of the window
    def get(sym, opts = nil)
      case sym
      when :window;          self
      when :title;           @title
      when :background;      @background
      when :width;           @width
      when :height;          @height
      when :viewport_width;  @viewport_width
      when :viewport_height; @viewport_height
      when :display_width, :display_height
        ext_get_display_dimensions
        if sym == :display_width
          @display_width
        else
          @display_height
        end
      when :resizable;       @resizable
      when :borderless;      @borderless
      when :fullscreen;      @fullscreen
      when :highdpi;         @highdpi
      when :frames;          @frames
      when :fps;             @fps
      when :fps_cap;         @fps_cap
      when :mouse_x;         @mouse_x
      when :mouse_y;         @mouse_y
      when :diagnostics;     @diagnostics
      when :screenshot;      screenshot(opts)
      end
    end

    # Set a window attribute
    def set(opts)
      # Store new window attributes, or ignore if nil
      @title           = opts[:title]           || @title
      if Color.is_valid? opts[:background]
        @background    = Color.new(opts[:background])
      end
      @icon            = opts[:icon]            || @icon
      @width           = opts[:width]           || @width
      @height          = opts[:height]          || @height
      @fps_cap         = opts[:fps_cap]         || @fps_cap
      @viewport_width  = opts[:viewport_width]  || @viewport_width
      @viewport_height = opts[:viewport_height] || @viewport_height
      @resizable       = opts[:resizable]       || @resizable
      @borderless      = opts[:borderless]      || @borderless
      @fullscreen      = opts[:fullscreen]      || @fullscreen
      @highdpi         = opts[:highdpi]         || @highdpi
      unless opts[:diagnostics].nil?
        @diagnostics = opts[:diagnostics]
        ext_diagnostics(@diagnostics)
      end
    end

    # Add an object to the window
    def add(o)
      case o
      when nil
        raise Error, "Cannot add '#{o.class}' to window!"
      when Array
        o.each { |x| add_object(x) }
      else
        add_object(o)
      end
    end

    # Remove an object from the window
    def remove(o)
      if o == nil
        raise Error, "Cannot remove '#{o.class}' from window!"
      end

      if i = @objects.index(o)
        @objects.delete_at(i)
        true
      else
        false
      end
    end

    # Clear all objects from the window
    def clear
      @objects.clear
    end

    # Set an update callback
    def update(&proc)
      @update_proc = proc
      true
    end

    # Generate a new event key (ID)
    def new_event_key
      @event_key = @event_key.next
    end

    # Set an event handler
    def on(event, &proc)
      unless @events.has_key? event
        raise Error, "`#{event}` is not a valid event type"
      end
      event_id = new_event_key
      @events[event][event_id] = proc
      EventDescriptor.new(event, event_id)
    end

    # Remove an event handler
    def off(event_descriptor)
      @events[event_descriptor.type].delete(event_descriptor.id)
    end

    # Key callback method, called by the native and web extentions
    def key_callback(type, key)
      key = key.downcase

      # All key events
      @events[:key].each do |id, e|
        e.call(KeyEvent.new(type, key))
      end

      case type
      # When key is pressed, fired once
      when :down
        @events[:key_down].each do |id, e|
          e.call(KeyEvent.new(type, key))
        end
      # When key is being held down, fired every frame
      when :held
        @events[:key_held].each do |id, e|
          e.call(KeyEvent.new(type, key))
        end
      # When key released, fired once
      when :up
        @events[:key_up].each do |id, e|
          e.call(KeyEvent.new(type, key))
        end
      end
    end

    # Mouse callback method, called by the native and web extentions
    def mouse_callback(type, button, direction, x, y, delta_x, delta_y)
      # All mouse events
      @events[:mouse].each do |id, e|
        e.call(MouseEvent.new(type, button, direction, x, y, delta_x, delta_y))
      end

      case type
      # When mouse button pressed
      when :down
        @events[:mouse_down].each do |id, e|
          e.call(MouseEvent.new(type, button, nil, x, y, nil, nil))
        end
      # When mouse button released
      when :up
        @events[:mouse_up].each do |id, e|
          e.call(MouseEvent.new(type, button, nil, x, y, nil, nil))
        end
      # When mouse motion / movement
      when :scroll
        @events[:mouse_scroll].each do |id, e|
          e.call(MouseEvent.new(type, nil, direction, nil, nil, delta_x, delta_y))
        end
      # When mouse scrolling, wheel or trackpad
      when :move
        @events[:mouse_move].each do |id, e|
          e.call(MouseEvent.new(type, nil, nil, x, y, delta_x, delta_y))
        end
      end
    end

    # Add controller mappings from file
    def add_controller_mappings
      if File.exist? @controller_mappings
        ext_add_controller_mappings(@controller_mappings)
      end
    end

    # Controller callback method, called by the native and web extentions
    def controller_callback(which, type, axis, value, button)
      # All controller events
      @events[:controller].each do |id, e|
        e.call(ControllerEvent.new(which, type, axis, value, button))
      end

      case type
      # When controller axis motion, like analog sticks
      when :axis
        @events[:controller_axis].each do |id, e|
          e.call(ControllerAxisEvent.new(which, axis, value))
        end
      # When controller button is pressed
      when :button_down
        @events[:controller_button_down].each do |id, e|
          e.call(ControllerButtonEvent.new(which, button))
        end
      # When controller button is released
      when :button_up
        @events[:controller_button_up].each do |id, e|
          e.call(ControllerButtonEvent.new(which, button))
        end
      end
    end

    # Update callback method, called by the native and web extentions
    def update_callback
      @update_proc.call

      # Accept and eval commands if in console mode
      if @console
        if STDIN.ready?
          cmd = STDIN.gets
          begin
            res = eval(cmd, TOPLEVEL_BINDING)
            STDOUT.puts "=> #{res.inspect}"
            STDOUT.flush
          rescue SyntaxError => se
            STDOUT.puts se
            STDOUT.flush
          rescue Exception => e
            STDOUT.puts e
            STDOUT.flush
          end
        end
      end

    end

    # Show the window
    def show
      ext_show
    end

    # Take screenshot
    def screenshot(path)
      if path
        ext_screenshot(path)
      else
        if RUBY_ENGINE == 'ruby'
          time = Time.now.utc.strftime '%Y-%m-%d--%H-%M-%S'
        else
          time = Time.now.utc.to_i
        end
        ext_screenshot("./screenshot-#{time}.png")
      end
    end

    # Close the window
    def close
      ext_close
    end

    # Private instance methods

    private

    # An an object to the window, used by the public `add` method
    def add_object(o)
      if !@objects.include?(o)
        index = @objects.index do |object|
          object.z > o.z
        end
        if index
          @objects.insert(index, o)
        else
          @objects.push(o)
        end
        true
      else
        false
      end
    end

  end
end


# Ruby2D::DSL

module Ruby2D::DSL

  Ruby2D::Window.new

  def get(sym, opts = nil)
    Window.get(sym, opts)
  end

  def set(opts)
    Window.set(opts)
  end

  def on(event, &proc)
    Window.on(event, &proc)
  end

  def off(event_descriptor)
    Window.off(event_descriptor)
  end

  def update(&proc)
    Window.update(&proc)
  end

  def clear
    Window.clear
  end

  def show
    Window.show
  end

  def close
    Window.close
  end

end


# Ruby2D::Quad

module Ruby2D
  class Quad
    include Renderable

    # Coordinates in clockwise order, starting at top left:
    # x1,y1 == top left
    # x2,y2 == top right
    # x3,y3 == bottom right
    # x4,y4 == bottom left
    attr_accessor :x1, :y1, :c1,
                  :x2, :y2, :c2,
                  :x3, :y3, :c3,
                  :x4, :y4, :c4

    def initialize(opts = {})
      @x1 = opts[:x1] || 0
      @y1 = opts[:y1] || 0
      @x2 = opts[:x2] || 100
      @y2 = opts[:y2] || 0
      @x3 = opts[:x3] || 100
      @y3 = opts[:y3] || 100
      @x4 = opts[:x4] || 0
      @y4 = opts[:y4] || 100
      @z  = opts[:z]  || 0
      self.color = opts[:color] || 'white'
      self.opacity = opts[:opacity] if opts[:opacity]
      add
    end

    def color=(c)
      @color = Color.set(c)
      update_color(@color)
    end

    # The logic is the same as for a triangle
    # See triangle.rb for reference
    def contains?(x, y)
      self_area = triangle_area(@x1, @y1, @x2, @y2, @x3, @y3) +
                  triangle_area(@x1, @y1, @x3, @y3, @x4, @y4)

      questioned_area = triangle_area(@x1, @y1, @x2, @y2, x, y) +
                        triangle_area(@x2, @y2, @x3, @y3, x, y) +
                        triangle_area(@x3, @y3, @x4, @y4, x, y) +
                        triangle_area(@x4, @y4, @x1, @y1, x, y)

      questioned_area <= self_area
    end

    private

    def triangle_area(x1, y1, x2, y2, x3, y3)
      (x1*y2 + x2*y3 + x3*y1 - x3*y2 - x1*y3 - x2*y1).abs / 2
    end

    def update_color(c)
      if c.is_a? Color::Set
        if c.length == 4
          @c1 = c[0]
          @c2 = c[1]
          @c3 = c[2]
          @c4 = c[3]
        else
          raise ArgumentError, "`#{self.class}` requires 4 colors, one for each vertex. #{c.length} were given."
        end
      else
        @c1 = c
        @c2 = c
        @c3 = c
        @c4 = c
      end
    end

  end
end


# Ruby2D::Line

module Ruby2D
  class Line
    include Renderable

    attr_accessor :x1, :x2, :y1, :y2, :width

    def initialize(opts = {})
      @x1 = opts[:x1] || 0
      @y1 = opts[:y1] || 0
      @x2 = opts[:x2] || 100
      @y2 = opts[:y2] || 100
      @z = opts[:z] || 0
      @width = opts[:width] || 2
      self.color = opts[:color] || 'white'
      self.opacity = opts[:opacity] if opts[:opacity]
      add
    end

    def color=(c)
      @color = Color.set(c)
      update_color(@color)
    end

    # Return the length of the line
    def length
      points_distance(@x1, @y1, @x2, @y2)
    end

    # Line contains a point if the point is closer than the length of line from
    # both ends and if the distance from point to line is smaller than half of
    # the width. For reference:
    #   https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
    def contains?(x, y)
      points_distance(x1, y1, x, y) <= length &&
      points_distance(x2, y2, x, y) <= length &&
      (((@y2 - @y1) * x - (@x2 - @x1) * y + @x2 * @y1 - @y2 * @x1).abs / length) <= 0.5 * @width
    end

    private

    # Calculate the distance between two points
    def points_distance(x1, y1, x2, y2)
      Math.sqrt((x1 - x2) ** 2 + (y1 - y2) ** 2)
    end

    def update_color(c)
      if c.is_a? Color::Set
        if c.length == 4
          @c1 = c[0]
          @c2 = c[1]
          @c3 = c[2]
          @c4 = c[3]
        else
          raise ArgumentError, "`#{self.class}` requires 4 colors, one for each vertex. #{c.length} were given."
        end
      else
        @c1 = c
        @c2 = c
        @c3 = c
        @c4 = c
      end
    end

  end
end


# Ruby2D::Circle

module Ruby2D
  class Circle
    include Renderable

    attr_accessor :x, :y, :radius, :sectors

    def initialize(opts = {})
      @x = opts[:x] || 25
      @y = opts[:y] || 25
      @z = opts[:z] || 0
      @radius = opts[:radius] || 25
      @sectors = opts[:sectors] || 20
      self.color = opts[:color] || 'white'
      self.opacity = opts[:opacity] if opts[:opacity]
      add
    end

    def contains?(x, y)
      Math.sqrt((x - @x)**2 + (y - @y)**2) <= @radius
    end

  end
end


# Ruby2D::Rectangle

module Ruby2D
  class Rectangle < Quad

    def initialize(opts = {})
      @x = opts[:x] || 0
      @y = opts[:y] || 0
      @z = opts[:z] || 0
      @width = opts[:width] || 200
      @height = opts[:height] || 100
      self.color = opts[:color] || 'white'
      self.opacity = opts[:opacity] if opts[:opacity]
      update_coords(@x, @y, @width, @height)
      add
    end

    def x=(x)
      @x = @x1 = x
      @x2 = x + @width
      @x3 = x + @width
      @x4 = x
    end

    def y=(y)
      @y = @y1 = y
      @y2 = y
      @y3 = y + @height
      @y4 = y + @height
    end

    def width=(w)
      @width = w
      update_coords(@x, @y, w, @height)
    end

    def height=(h)
      @height = h
      update_coords(@x, @y, @width, h)
    end

    private

    def update_coords(x, y, w, h)
      @x1 = x
      @y1 = y
      @x2 = x + w
      @y2 = y
      @x4 = x
      @y4 = y + h
      @x3 = x + w
      @y3 = y + h
    end

  end
end


# Ruby2D::Square

module Ruby2D
  class Square < Rectangle

    attr_reader :size

    def initialize(opts = {})
      @x = opts[:x] || 0
      @y = opts[:y] || 0
      @z = opts[:z] || 0
      @width = @height = @size = opts[:size] || 100
      self.color = opts[:color] || 'white'
      self.opacity = opts[:opacity] if opts[:opacity]
      update_coords(@x, @y, @size, @size)
      add
    end

    # Set the size of the square
    def size=(s)
      self.width = self.height = @size = s
    end

    # Make the inherited width and height attribute accessors private
    private :width=, :height=

  end
end


# Ruby2D::Triangle

module Ruby2D
  class Triangle
    include Renderable

    attr_accessor :x1, :y1, :c1,
                  :x2, :y2, :c2,
                  :x3, :y3, :c3

    def initialize(opts= {})
      @x1 = opts[:x1] || 50
      @y1 = opts[:y1] || 0
      @x2 = opts[:x2] || 100
      @y2 = opts[:y2] || 100
      @x3 = opts[:x3] || 0
      @y3 = opts[:y3] || 100
      @z  = opts[:z]  || 0
      self.color = opts[:color] || 'white'
      self.opacity = opts[:opacity] if opts[:opacity]
      add
    end

    def color=(c)
      @color = Color.set(c)
      update_color(@color)
    end

    # A point is inside a triangle if the area of 3 triangles, constructed from
    # triangle sides and the given point, is equal to the area of triangle.
    def contains?(x, y)
      self_area = triangle_area(@x1, @y1, @x2, @y2, @x3, @y3)
      questioned_area =
        triangle_area(@x1, @y1, @x2, @y2, x, y) +
        triangle_area(@x2, @y2, @x3, @y3, x, y) +
        triangle_area(@x3, @y3, @x1, @y1, x, y)

      questioned_area <= self_area
    end

    private

    def triangle_area(x1, y1, x2, y2, x3, y3)
      (x1*y2 + x2*y3 + x3*y1 - x3*y2 - x1*y3 - x2*y1).abs / 2
    end

    def update_color(c)
      if c.is_a? Color::Set
        if c.length == 3
          @c1 = c[0]
          @c2 = c[1]
          @c3 = c[2]
        else
          raise ArgumentError, "`#{self.class}` requires 3 colors, one for each vertex. #{c.length} were given."
        end
      else
        @c1 = c
        @c2 = c
        @c3 = c
      end
    end

  end
end


# Ruby2D::Image

module Ruby2D
  class Image
    include Renderable

    attr_reader :path
    attr_accessor :x, :y, :width, :height, :rotate, :data

    def initialize(path, opts = {})
      unless File.exist? path
        raise Error, "Cannot find image file `#{path}`"
      end
      @path = path
      @x = opts[:x] || 0
      @y = opts[:y] || 0
      @z = opts[:z] || 0
      @width = opts[:width] || nil
      @height = opts[:height] || nil
      @rotate = opts[:rotate] || 0
      self.color = opts[:color] || 'white'
      self.opacity = opts[:opacity] if opts[:opacity]
      unless ext_init(@path)
        raise Error, "Image `#{@path}` cannot be created"
      end
      add
    end

  end
end


# Ruby2D::Sprite

module Ruby2D
  class Sprite
    include Renderable

    attr_reader :path
    attr_accessor :rotate, :loop, :clip_x, :clip_y, :clip_width, :clip_height, :data

    def initialize(path, opts = {})
      unless File.exist? path
        raise Error, "Cannot find sprite image file `#{path}`"
      end

      # Sprite image file path
      @path = path

      # Coordinates, size, and rotation of the sprite
      @x = opts[:x] || 0
      @y = opts[:y] || 0
      @z = opts[:z] || 0
      @width  = opts[:width]  || nil
      @height = opts[:height] || nil
      @rotate = opts[:rotate] || 0
      self.color = opts[:color] || 'white'
      self.opacity = opts[:opacity] if opts[:opacity]

      # Flipping status, coordinates, and size, used internally
      @flip = nil
      @flip_x = @x
      @flip_y = @y
      @flip_width  = @width
      @flip_height = @height

      # Animation attributes
      @start_time = 0.0
      @loop = opts[:loop] || false
      @frame_time = opts[:time] || 300
      @animations = opts[:animations] || {}
      @playing = false
      @current_frame = opts[:default] || 0
      @last_frame = 0
      @done_proc = nil

      # The sprite image size set by the native extension `ext_init()`
      @img_width = nil; @img_height = nil

      # Initialize the sprite
      unless ext_init(@path)
        raise Error, "Sprite image `#{@path}` cannot be created"
      end

      # The clipping rectangle
      @clip_x = opts[:clip_x] || 0
      @clip_y = opts[:clip_y] || 0
      @clip_width  = opts[:clip_width]  || @img_width
      @clip_height = opts[:clip_height] || @img_height

      # Set the default animation
      @animations[:default] = 0..(@img_width / @clip_width) - 1

      # Set the sprite defaults
      @defaults = {
        animation:   @animations.first[0],
        frame:       @current_frame,
        frame_time:  @frame_time,
        clip_x:      @clip_x,
        clip_y:      @clip_y,
        clip_width:  @clip_width,
        clip_height: @clip_height,
        loop:        @loop
      }

      # Add the sprite to the window
      add
    end

    # Set the x coordinate
    def x=(x)
      @x = @flip_x = x
      if @flip == :horizontal || @flip == :both
        @flip_x = x + @width
      end
    end

    # Set the y coordinate
    def y=(y)
      @y = @flip_y = y
      if @flip == :vertical || @flip == :both
        @flip_y = y + @height
      end
    end

    # Set the width
    def width=(width)
      @width = @flip_width = width
      if @flip == :horizontal || @flip == :both
        @flip_width = -width
      end
    end

    # Set the height
    def height=(height)
      @height = @flip_height = height
      if @flip == :vertical || @flip == :both
        @flip_height = -height
      end
    end

    # Play an animation
    def play(opts = {}, &done_proc)

      animation = opts[:animation]
      loop = opts[:loop]
      flip = opts[:flip]

      if !@playing || (animation != @playing_animation && animation != nil) || flip != @flip

        @playing = true
        @playing_animation = animation || :default
        frames = @animations[@playing_animation]
        flip_sprite(flip)
        @done_proc = done_proc

        case frames
        # When animation is a range, play through frames horizontally
        when Range
          @first_frame   = frames.first || @defaults[:frame]
          @current_frame = frames.first || @defaults[:frame]
          @last_frame    = frames.last
        # When array...
        when Array
          @first_frame   = 0
          @current_frame = 0
          @last_frame    = frames.length - 1
        end

        # Set looping
        @loop = loop == true || @defaults[:loop] ? true : false

        set_frame
        restart_time
      end
    end

    # Stop the current animation and set to the default frame
    def stop(animation = nil)
      if !animation || animation == @playing_animation
        @playing = false
        @playing_animation = @defaults[:animation]
        @current_frame = @defaults[:frame]
        set_frame
      end
    end

    # Flip the sprite
    def flip_sprite(flip)

      # The sprite width and height must be set for it to be flipped correctly
      if (!@width || !@height) && flip
        raise Error,
         "Sprite width and height must be set in order to flip; " +
         "occured playing animation `:#{@playing_animation}` with image `#{@path}`"
      end

      @flip = flip

      # Reset flip values
      @flip_x      = @x
      @flip_y      = @y
      @flip_width  = @width
      @flip_height = @height

      case flip
      when :horizontal
        @flip_x      = @x + @width
        @flip_width  = -@width
      when :vertical
        @flip_y      = @y + @height
        @flip_height = -@height
      when :both     # horizontal and vertical
        @flip_x      = @x + @width
        @flip_width  = -@width
        @flip_y      = @y + @height
        @flip_height = -@height
      end
    end

    # Reset frame to defaults
    def reset_clipping_rect
      @clip_x      = @defaults[:clip_x]
      @clip_y      = @defaults[:clip_y]
      @clip_width  = @defaults[:clip_width]
      @clip_height = @defaults[:clip_height]
    end

    # Set the position of the clipping retangle based on the current frame
    def set_frame
      frames = @animations[@playing_animation]
      case frames
      when Range
        reset_clipping_rect
        @clip_x = @current_frame * @clip_width
      when Array
        f = frames[@current_frame]
        @clip_x      = f[:x]      || @defaults[:clip_x]
        @clip_y      = f[:y]      || @defaults[:clip_y]
        @clip_width  = f[:width]  || @defaults[:clip_width]
        @clip_height = f[:height] || @defaults[:clip_height]
        @frame_time  = f[:time]   || @defaults[:frame_time]
      end
    end

    # Calculate the time in ms
    def elapsed_time
      (Time.now.to_f - @start_time) * 1000
    end

    # Restart the timer
    def restart_time
      @start_time = Time.now.to_f
    end

    # Update the sprite animation, called by `Sprite#ext_render`
    def update
      if @playing

        # Advance the frame
        unless elapsed_time <= (@frame_time || @defaults[:frame_time])
          @current_frame += 1
          restart_time
        end

        # Reset to the starting frame if all frames played
        if @current_frame > @last_frame
          @current_frame = @first_frame
          unless @loop
            # Stop animation and play block, if provided
            stop
            if @done_proc then @done_proc.call end
            @done_proc = nil
          end
        end

        set_frame
      end
    end

  end
end


# Ruby2D::Font

module Ruby2D
  class Font

    class << self

      # List all fonts, names only
      def all
        all_paths.map { |path| path.split('/').last.chomp('.ttf').downcase }.uniq.sort
      end

      # Find a font file path from its name
      def path(font_name)
        all_paths.find { |path| path.downcase.include?(font_name) }
      end

      # Get all fonts with full file paths
      def all_paths
        # MRuby does not have `Dir` defined
        if RUBY_ENGINE == 'mruby'
          fonts = `find #{directory} -name *.ttf`.split("\n")
        # If MRI and/or non-Bash shell (like cmd.exe)
        else
          fonts = Dir["#{directory}/**/*.ttf"]
        end

        fonts = fonts.reject do |f|
          f.downcase.include?('bold')    ||
          f.downcase.include?('italic')  ||
          f.downcase.include?('oblique') ||
          f.downcase.include?('narrow')  ||
          f.downcase.include?('black')
        end

        fonts.sort_by { |f| f.downcase.chomp '.ttf' }
      end

      # Get the default font
      def default
        if all.include? 'arial'
          path 'arial'
        else
          all_paths.first
        end
      end

      # Get the fonts directory for the current platform
      def directory
        macos_font_path   = '/Library/Fonts'
        linux_font_path   = '/usr/share/fonts'
        windows_font_path = 'C:/Windows/Fonts'

        # If MRI and/or non-Bash shell (like cmd.exe)
        if Object.const_defined? :RUBY_PLATFORM
          case RUBY_PLATFORM
          when /darwin/  # macOS
            macos_font_path
          when /linux/
            linux_font_path
          when /mingw/
            windows_font_path
          end
        # If MRuby
        else
          if `uname`.include? 'Darwin'  # macOS
            macos_font_path
          elsif `uname`.include? 'Linux'
            linux_font_path
          elsif `uname`.include? 'MINGW'
            windows_font_path
          end
        end
      end

    end

  end
end


# Ruby2D::Text

module Ruby2D
  class Text
    include Renderable

    attr_reader :text, :font
    attr_accessor :x, :y, :size, :rotate, :data

    def initialize(text, opts = {})
      @x = opts[:x] || 0
      @y = opts[:y] || 0
      @z = opts[:z] || 0
      @text = text.to_s
      @size = opts[:size] || 20
      @rotate = opts[:rotate] || 0
      self.color = opts[:color] || 'white'
      self.opacity = opts[:opacity] if opts[:opacity]
      @font = opts[:font] || Font.default
      unless File.exist? @font
        raise Error, "Cannot find font file `#{@font}`"
      end
      unless ext_init
        raise Error, "Text `#{@text}` cannot be created"
      end
      add
    end

    def text=(msg)
      @text = msg.to_s
      ext_set(@text)
    end

  end
end


# Ruby2D::Sound

module Ruby2D
  class Sound

    attr_reader :path
    attr_accessor :data

    def initialize(path)
      unless File.exist? path
        raise Error, "Cannot find audio file `#{path}`"
      end
      @path = path
      unless ext_init(@path)
        raise Error, "Sound `#{@path}` cannot be created"
      end
    end

    # Play the sound
    def play
      ext_play
    end

  end
end


# Ruby2D::Music

module Ruby2D
  class Music

    attr_reader :path
    attr_accessor :loop, :data

    def initialize(path, opts = {})
      unless File.exist? path
        raise Error, "Cannot find audio file `#{path}`"
      end
      @path = path
      @loop = opts[:loop] || false
      unless ext_init(@path)
        raise Error, "Music `#{@path}` cannot be created"
      end
    end

    # Play the music
    def play
      ext_play
    end

    # Pause the music
    def pause
      ext_pause
    end

    # Resume paused music
    def resume
      ext_resume
    end

    # Stop playing the music, start at beginning
    def stop
      ext_stop
    end

    # Returns the volume, in percentage
    def self.volume
      self.ext_get_volume
    end

    # Set music volume, 0 to 100%
    def self.volume=(v)
      # If a negative value, volume will be 0
      if v < 0 then v = 0 end
      self.ext_set_volume(v)
    end

    # Alias instance methods to class methods
    def volume; Music.volume end
    def volume=(v); Music.volume=(v) end

    # Fade out music over provided milliseconds
    def fadeout(ms)
      ext_fadeout(ms)
    end

  end
end


# Ruby2D module and native extension loader, adds DSL

unless RUBY_ENGINE == 'mruby'
  require 'ruby2d/cli/colorize'
  require 'ruby2d/exceptions'
  require 'ruby2d/renderable'
  require 'ruby2d/color'
  require 'ruby2d/window'
  require 'ruby2d/dsl'
  require 'ruby2d/quad'
  require 'ruby2d/line'
  require 'ruby2d/circle'
  require 'ruby2d/rectangle'
  require 'ruby2d/square'
  require 'ruby2d/triangle'
  require 'ruby2d/image'
  require 'ruby2d/sprite'
  require 'ruby2d/font'
  require 'ruby2d/text'
  require 'ruby2d/sound'
  require 'ruby2d/music'

  if RUBY_PLATFORM =~ /mingw/
    s2d_dll_path = Gem::Specification.find_by_name('ruby2d').gem_dir + '/assets/mingw/bin'
    RubyInstaller::Runtime.add_dll_directory(File.expand_path(s2d_dll_path))
  end

  require 'ruby2d/ruby2d'  # load native extension
end


module Ruby2D

  @assets = nil

  class << self
    def assets
      unless @assets
        if RUBY_ENGINE == 'mruby'
          @assets = Ruby2D.ext_base_path + 'assets'
        else
          @assets = './assets'
        end
      end
      @assets
    end

    def assets=(path); @assets = path end
  end
end

include Ruby2D
extend  Ruby2D::DSL


