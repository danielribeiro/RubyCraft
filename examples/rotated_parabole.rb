#!/usr/bin/env ruby
require 'example_helpers'
require 'fileutils'
require 'region'
require 'set'

include Bresenham
include ColorTopology
black = BlockColor.typeColor[BlockColor::InvertedColor[:black]].rgb
orderedColors =  BlockColor.typeColor.sort_by { |b| squaredColorDist(b.rgb, black) }

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
    b.data = orderedColors[y * 16 / 128].data
  else
    b.name = :air
  end
end
puts 'exporting'
r.exportToFile reg
puts 'done'