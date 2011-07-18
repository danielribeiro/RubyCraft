#!/usr/bin/env ruby
def ca(&block)
  puts "the result is"
  puts yield
end


ca