#!/usr/bin/env ruby
require 'mnedit'
puts "Starting"
reg = '/home/daniel/.minecraft/saves/LowDirt/region/r.0.0.mcr'
#reg = '/home/daniel/.minecraft/saves/newone/region/r.0.0.mcr'
Region.new(reg).readChunk 0, 0

