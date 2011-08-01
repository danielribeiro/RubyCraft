#!/usr/bin/env ruby
require 'example_helpers'
require 'region'
require 'set'

module Plots
  extend ColorTopology
  include Math
  black = BlockColor.typeColor[BlockColor::InvertedColor[:black]].rgb
  OrderedColors =  BlockColor.typeColor.sort_by { |b| squaredColorDist(b.rgb, black) }

  def halfSphere
    plotWith :ice do |x, z|
      sqrt(18**2 - x**2 - z **2) + 30
    end
  end

  def paraboloid
    plot(proc {|x, z| (x** 2 + z ** 2) / 3}, proc do |b, z, x, y|
        b.name = :wool; b.data = OrderedColors[y * 16 / 128].data
      end)
  end

  def rotatedSine
    plotWith :gold do |x, z|
      sin(sqrt((x** 2 + z ** 2)) / 2) * 10 + 30
    end
  end

  def hyperbolicParaboloid
    plotWith :water do |x, z|
      (x** 2 - z ** 2) / 3 + 50
    end
  end

  def cone
    plotWith :diamond_block do |x, z|
      sqrt((x** 2 + z ** 2) / 3) * 5 + 20
    end
  end

  def gnuplotSurface10
    plotWith :lava do |x, z|
      log(x ** 4 * z ** 2 + 2) + 20
    end
  end

  def gnuplotSurface15
    plotWith :netherrack do |x, z|
      (sin(sqrt(z ** 2 + z ** 2)) / sqrt(x ** 2 + z ** 2)) * 30 + 30
    end
  end

  def polynomial
    plotWith :log do |x, z|
      x /= 5
      z /= 5
      (x + z) ** 5 + x**3 + z**2 + 30
    end
  end

  def polynomialQuotient
    plotWith :obsidian do |x, z|
      p1 = (x + z) ** 6 - x ** 3 + z **2 + 50
      p2 = x ** 7 + 6* z ** 6 - x **4 - z**2 + 30
      p1 / p2 + 10
    end
  end
end


# Simple functioning plotting
class PlottingExample
  include Bresenham
  include Plots
  attr_accessor :size
  attr_reader :height
  def initialize(regionFile)
    @z = padding
    @x = padding
    @y = 1
    @size = 3 * 16
    @height = 127
    @regionFile = regionFile
    @region = Region.fromFile(regionFile)
  end

  def width
    size - 2 * padding
  end

  def length
    size - 2 * padding
  end

  # for uniform plots
  def plotWith(fillBlock, &block)
    plot block, proc { |b| b.name = fillBlock}
  end

  def plot(function, fillFunction)
    cube = getCube
    middlePointX = length / 2
    middlePointZ = width / 2
    centeredF = proc do |x, z|
      function.call(x - middlePointX, z - middlePointZ).ceil
    end
    points = Set.new
    yzraster(centeredF, points)
    yxraster(centeredF, points)
    modifyBlocks(cube, centeredF, fillFunction, points)
  end



  def save
    @region.exportToFile @regionFile
  end

  protected
  def modifyBlocks(cube, centeredF, fillFunction, points)
    cube.each do |b, z, x, y|
      if points.include?([z, x, y])
        args = [b, z, x, y].take(fillFunction.arity)
        fillFunction.call *args
      end
    end
  end

  def yxraster(centeredF, points)
    raster do |z, x|
      p1 = point(x, centeredF.call(x, z))
      p2 = point(x, centeredF.call(x + 1, z))
      for newx, y in draw_line p1, p2
        points.add [z,newx, y]
      end
    end
  end

  def raster(&block)
    for z in 0..width
      for x  in 0..length
        begin
          block.call(x, z)
        rescue Exception => ex
          # Ignroring infinites, complex numbers and non defined points
        end
      end
    end
  end

  def yzraster(centeredF, points)
    raster do |z, x|
      p1 = point(z, centeredF.call(x, z))
      p2 = point(z, centeredF.call(x, z + 1))
      for newz, y in draw_line p1, p2
        points.add [newz, x, y]
      end
    end
  end

  def getCube
    ret = @region.cube @z, @x, @y, :width => width, :length => length, :height => height
    @x += size
    if @x >= 3 * size
      @x = 0
      @z += size
    end
    return ret
  end

  def padding
    5
  end
end


if __FILE__ == $0
  puts "Starting"
  reg = '/home/daniel/.minecraft/saves/LowDirt/region/r.0.0.mcr'
  p = PlottingExample.new reg
  for type in Plots.public_instance_methods
    puts "Plotting #{type}"
    p.send type
  end
  puts 'exporting'
  p.save
  puts 'done'
end
