# Draw Mandelbrot set images
#
# arguments
#   1. width in pixel units
#   2. height in pixel units
#   3. zoom factor
#   4. camera centrum x in pixel units
#   5. camera centrum y in pixel units
#
# @example
#   ruby fractal.rb 1024 768 4 100 100

require 'chunky_png'
#require 'pry'

MAX_ITERS = 255
def colorAt(x, y)
  z = 0.0
  z_i = 0.0
  inset = true
  num_iterations = 0.0

  MAX_ITERS.times do |k|
    new_z = (z * z) - (z_i * z_i) + x;
    new_z_i = 2.0 * z * z_i + y;

    z = new_z
    z_i = new_z_i
    
    if (z * z + z_i * z_i) > 4.0
      inset = false
      num_iterations = k
      break
    end
  end

  if inset
    [0,0,0]
  else
    r = num_iterations % 256
    g = (num_iterations * 3) % 256 
    b = (num_iterations * 7 + 39) % 256
    [r, g, b]
  end
end

width = ARGV[0].to_i || 800
height = ARGV[1].to_i || 800
zoom = ARGV[2].to_i || 1
zoom = Math.sqrt(zoom)

png = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::TRANSPARENT)

# interesting location at 300 1200
cx = 0 || ARGV[3].to_i
cy = 0 || ARGV[4].to_i
center = [cx, cy]
density = 1

VIEWPORT_MIN_X = -2.5 / zoom
VIEWPORT_MIN_Y = -2.5 / zoom
VIEWPORT_MAX_X = 2.5 / zoom
VIEWPORT_MAX_Y = 2.5 / zoom
PIXEL_WIDTH = 1.0
PIXEL_HEIGHT = 1.0

# 1 pixel = k viewport units
viewportunits_per_pixel_width = (VIEWPORT_MAX_X - VIEWPORT_MIN_X) / width
viewportunits_per_pixel_height = (VIEWPORT_MAX_Y - VIEWPORT_MIN_Y) / height

width.times do |i|
  next unless (i % density == 0)
  ii = (i-center[0]) / PIXEL_WIDTH
  x = VIEWPORT_MIN_X + (ii * viewportunits_per_pixel_width);
  height.times do |j|
    next unless (j % density == 0)
    jj = (j-center[1]) / PIXEL_HEIGHT
    y = VIEWPORT_MIN_Y + (jj * viewportunits_per_pixel_height);
    rgb = colorAt(x, y)

    r = rgb[0]
    g = rgb[1]
    b = rgb[2]
    png[i, j] = ChunkyPNG::Color.rgba(r, g, b, 255)
  end
end
png.save('mandelbrot.png', :interlace => true)
