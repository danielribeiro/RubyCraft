#!/usr/bin/env ruby
$LOAD_PATH.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'rubygems'
require 'fileutils'
require 'rubycraft'
include RubyCraft
def file(name)
  File.join(File.dirname(__FILE__),'..','fixtures', name)
end
r = Region.fromFile file 'input.mcr'

for x in 0..2
  for z in 0..2
    puts "converting #{x} , #{z}"
    r.chunk(x, z).each do |b|
      if b.y == 63
        b.name = :wool
        b.data = (b.x + b.z) % 16
      end
    end
  end
end
output = file 'output.mcr'
r.exportToFile output
result = FileUtils.compare_file output, file('painted.mcr')
if result
  puts "ok They Are the same"
else
  puts "FAIL!!! NOT the same"
end

 
