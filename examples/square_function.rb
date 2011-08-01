#!/usr/bin/env ruby
$LOAD_PATH.unshift File.join(File.dirname(__FILE__),'..','lib')
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
r.cube(0, 0, 0, :width => 16 * 3, :length => 16 * 3, :height => 128) do |b, z, x, y|
  fy = f(x, z)
  if y <= fy
    b.name = :wool
    b.data = (x + z) % 16
  else
    b.name = :air
  end
end
puts 'exporting'
r.exportToFile reg
puts 'done'