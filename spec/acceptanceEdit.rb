#!/usr/bin/env ruby
$LOAD_PATH.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'fileutils'
require 'mnedit'
def file(name)
  File.join(File.dirname(__FILE__),'..','fixtures', name)
end

input = file 'input.mcr'
r = Region.new(input)
output = file 'output.mcr'
r.file = output
r.convertChunks { |x, y| x <= 2 && y <=2}
result = FileUtils.compare_file output, file('painted.mcr')
if result
  puts "ok They Are the same"
else
  puts "FAIL!!! NOT the same"
end
