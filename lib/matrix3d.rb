#!/usr/bin/env ruby
class IndexOutOfBoundsError < StandardError
  
end

class Matrix3d
  include Enumerable

  def initialize(d1,d2,d3)
    @xlimit = d1
    @ylimit = d2
    @zlimit = d3
    @data = Array.new(d1) { Array.new(d2) { Array.new(d3) } }
  end

  def [](x, y, z)
    checkBounds x, y, z
    @data[x][y][z]
  end

  def []=(x, y, z, value)
    checkBounds x, y, z
    @data[x][y][z] = value
  end

  def put(index, value)
    ar = indexToArray(index)
    self[*ar] = value
  end

  def get(index)
    ar = indexToArray(index)
    self[*ar]
  end

  def each(&block)
    for z in @data
      for y in z
        for x in y
          yield x
        end
      end
    end
  end

  def each_triple_index(&block)
    return enum_for:each_triple_index unless block_given?
    @data.each_with_index do |plane, x|
      plane.each_with_index do |column, y|
        column.each_with_index do |value, z|
          yield value, [x ,y ,z]
        end
      end
    end
  end

  #Actually from any iterable
  def fromArray(ar)
    ar.each_with_index { |obj,i| put i, obj }
    return self
  end


  def to_a(default = nil)
    map do |x|
      if x.nil?
        default
      else
        x
      end
    end
  end

  protected
  def indexToArray(index)
    x = index / (@zlimit * @ylimit)
    index -= x * (@zlimit * @ylimit)
    y = index / @zlimit
    z = index % @zlimit
    return x, y, z
  end


  def checkBounds(x, y, z)
    within x, @xlimit
    within y, @ylimit
    within z, @zlimit
  end

  def within(value, limit)

    raise IndexOutOfBoundsError if value < 0 or value >= limit
  end
end