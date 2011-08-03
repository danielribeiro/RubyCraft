$LOAD_PATH.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'rubygems'
require 'rubycraft'
include RubyCraft

module ColorTopology
  def squaredColorDist(c1, c2)
    c1.zip(c2).map do |x1, x2|
      (x1 - x2) ** 2
    end.inject :+
    end

  def closest_color(colorArray)
    BlockColor.typeColor.min_by do |c|
      squaredColorDist(c.rgb, colorArray)
    end
  end
end



# From http://rosettacode.org/wiki/Bitmap/Bresenham%27s_line_algorithm#Ruby
module Bresenham
  Point2D = Struct.new :x, :y
  def point(x, y)
    Point2D.new x, y
  end

  def draw_line(p1, p2)
    ret = []
    x1, y1 = p1.x, p1.y
    x2, y2 = p2.x, p2.y

    steep = (y2 - y1).abs > (x2 - x1).abs

    if steep
      x1, y1 = y1, x1
      x2, y2 = y2, x2
    end

    if x1 > x2
      x1, x2 = x2, x1
      y1, y2 = y2, y1
    end

    deltax = x2 - x1
    deltay = (y2 - y1).abs
    error = deltax / 2
    ystep = y1 < y2 ? 1 : -1

    y = y1
    x1.upto(x2) do |x|
      pixel = steep ? [y,x] : [x,y]
      ret << pixel
      error -= deltay
      if error < 0
        y += ystep
        error += deltax
      end
    end
    return ret
  end
end
