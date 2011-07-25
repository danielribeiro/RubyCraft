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
    @blocks = Matrix3d.new(16, 16, 128).fromArray bytes.map {|byte| Block.get(byte) }
    @blocks.each_triple_index do |b, pos|
      b.pos = pos
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
    newData = @blocks.map { |b| b.id }
    newblocks = NBTFile::Types::ByteArray.new ByteConverter.toByteString newData
    @nbtBody["Level"]["Blocks"] = newblocks
    ["", @nbtBody]
  end


end
