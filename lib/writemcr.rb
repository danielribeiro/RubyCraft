#!/usr/bin/env ruby
require 'rubygems'
require 'fileutils'
require 'region'

def f(x, z)
  x -= 16
  z -= 16
  (((x**2 + z**2))) / 4
end

puts "Starting"
reg = '/home/daniel/.minecraft/saves/newone/region/r.0.0.mcr'
r = Region.fromFile(reg)
for cx in 0..2
  for cz in 0..2
    puts "converting #{cx} , #{cz}"
    r.chunk(cx, cz).each do |b|
      x = cx * 16 + b.x
      z = cz * 16 + b.z
      y = f(x, z)
      if b.y == y
        b.name = :wool
        b.data = (x + z) % 16
      else
        b.name = :air
      end
    end
  end
end
puts 'exporting'
r.exportToFile reg