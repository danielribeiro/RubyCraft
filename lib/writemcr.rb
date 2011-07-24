#!/usr/bin/env ruby
require 'mnedit'
puts "Starting"
reg = '/home/daniel/.minecraft/saves/newone/region/r.0.0.mcr'
Region.new(reg).convertChunks { |x, y| x <= 2 && y <=2}
puts "moved!"
