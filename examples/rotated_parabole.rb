#!/usr/bin/env ruby
$LOAD_PATH.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'rubygems'
require 'fileutils'
require 'region'
require 'set'

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

include Bresenham

def f(x, z)
  x -= 16
  z -= 16
  (((x**2 + z**2))) / 4
end

puts "Starting"
reg = '/home/daniel/.minecraft/saves/newone/region/r.0.0.mcr'
points = Set.new
r = Region.fromFile(reg)
for z in 0.upto(16 * 3)
  for x  in 0.upto(16 * 3)
    p1 = point(z, f(x, z))
    p2 = point(z, f(x, z + 1))
    for newz, y in draw_line p1, p2
      points.add [newz, x, y]
    end
  end
end

for z in 0.upto(16 * 3)
  for x  in 0.upto(16 * 3)
    p1 = point(x, f(x, z))
    p2 = point(x, f(x + 1, z))
    for newx, y in draw_line p1, p2
      points.add [z, newx, y]
    end
  end
end
r.cube(0, 0, 0, :width => 16 * 3, :length => 16 * 3, :height => 128) do |b, z, x, y|
  if points.include?([z, x, y])
    b.name = :wool
    b.data = (x + z) % 16
  else
    b.name = :air
  end
end
puts 'exporting'
r.exportToFile reg
puts 'done'