#!/usr/bin/env ruby
# Represents a chunk data
require 'nbt_helper'
require 'byte_converter'
require 'block'
require 'matrix3d'

class Chunk
  include Enumerable

  def initialize(nbtData)
    name, @nbtBody = nbtData
  end

  # Converts all blocks on data do another type
  def block_map(&block)
    mapEachBlock { |b| Block[block.call(b)] }
  end

  def block_type_map(&block)
    mapEachBlock { |b| Block[block.call(b.name.to_sym)]}
  end

  def export
    ["", @nbtBody]
  end

  def each(&block)
    blocks = @nbtBody["Level"]["Blocks"].value.bytes
    m = Matrix3d.new(16, 16, 128).fromArray(blocks)
    newData = []


    @nbtBody["Level"]["Blocks"] = NBTFile::Types::ByteArray.new ByteConverter.toByteString newData
  end

  protected
  def mapEachBlock(&block)
    counter = ChunkCounter.new
    newData = @nbtBody["Level"]["Blocks"].value.bytes.map do |byte|
      b = Block.get(byte)
      b.pos = counter.posInc
      block.call(b).id
    end
    @nbtBody["Level"]["Blocks"] = NBTFile::Types::ByteArray.new ByteConverter.toByteString newData
  end
end

class ChunkCounter
  attr_reader :x, :y, :z

  def initialize
    @y = 0
    @z = 0
    @x = 0
  end

  def inc
    @y += 1
    if @y == 128
      @y = 0
      @z += 1
    end
    if @z == 16
      @z = 0
      @x += 1
    end
    pos
  end

  def pos
    [@y, @z, @x]
  end

  def posInc
    ret = pos
    inc
    ret
  end

end