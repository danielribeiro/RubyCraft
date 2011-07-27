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
    bytes = @nbtBody["Level"]["Blocks"].value.bytes
    @blocks = matrixfromBytes bytes
    @blocks.each_triple_index do |b, pos|
      b.pos = pos
    end
    data = @nbtBody["Level"]["Data"].value.bytes.to_a
    @blocks.each_with_index do |b, index|
      v = data[index / 2]
      if index % 2 == 0
        b.data = v & 0xF
      else
        b.data = v >> 4
      end
    end
  end


  # Iterates over the blocks
  def each(&block)
    @blocks.each &block
  end


  # Converts all blocks on data do another type. Gives the block and sets
  # the received name
  def block_map(&block)
    each { |b| b.name = yield b }
  end

  # Converts all blocks on data do another type. Gives the block name sets
  # the received name
  def block_type_map(&block)
    each { |b| b.name = yield b.name.to_sym }
  end

  def [](z, x, y)
    @blocks[z, x, y]
  end

  def []=(z, x, y, value)
    @blocks[z, x, y] = value
  end



  def export
    data = []
    @blocks.each_with_index do |b, i|
      if i % 2 == 0
        data << b.data
      else
        data[i / 2] += (b.data << 4)
      end
    end
    @nbtBody["Level"]["Data"] = byteArray data
    @nbtBody["Level"]["Blocks"] = byteArray @blocks.map { |b| b.id }
    ["", @nbtBody]
  end

  protected
  def byteArray(data)
    NBTFile::Types::ByteArray.new ByteConverter.toByteString(data)
  end

  def matrixfromBytes(bytes)
    Matrix3d.new(16, 16, 128).fromArray bytes.map {|byte| Block.get(byte) }
  end


end
