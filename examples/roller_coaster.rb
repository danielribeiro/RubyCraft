#!/usr/bin/env ruby
require 'plotting_example'

class RollerCoaster
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
    cube.each do |b, z, x, y|
      fxz = centeredF.call(x, z)
      if y == fxz
        args = [b, z, x, y].take(fillFunction.arity)
        fillFunction.call *args
      end
      if x == xRail
        onRail fxz, b, z, x, y, centeredF
      end
    end
  end

  def onRail(fxz, b, z, x, y, centeredF)
    cur = fxz + 1
    if cur == y
      b.name = :powered_rail
      before = centeredF.call(x, z - 1)
      after = centeredF.call(x, z + 1)
      if before > fxz
        b.data = 4
      elsif fxz < after
        b.data = 5
      else
        b.data = 0
      end
      b.data |= 8
    elsif fxz - 1 == y
      b.name = :redstone_torch_on
    elsif  fxz - 2 == y
      b.name = :gold
    end
  end

  def save
    @region.exportToFile @regionFile
  end

  protected
  def getCube
    @region.cube @z, @x, @y, :width => width, :length => length, :height => height
  end

  def padding
    5
  end

  def xRail
    42
  end

  def width
    32 * 16 - 2 * padding
  end

  def length
    5 * 16 - 2 * padding
  end
end

if __FILE__ == $0
  puts "Starting"
  reg = '/home/daniel/.minecraft/saves/LowDirt/region/r.0.0.mcr'
  p = RollerCoaster.new reg
  p.plotWith :gold do |x, z|
    Math.sin(Math.sqrt((x** 2 + z ** 2)) / 16) * 10 + 30
  end
  puts 'exporting'
  p.save
  puts 'done'
end