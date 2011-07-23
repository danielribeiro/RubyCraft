#!/usr/bin/env ruby
# Represents a chunk data
require 'nbt_helper'
require 'byte_converter'
require 'block'

class Chunk
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

  protected
  def mapEachBlock(&block)
    newData = @nbtBody["Level"]["Blocks"].value.bytes.map do |byte|
      block.call(Block.get(byte)).id
    end
    @nbtBody["Level"]["Blocks"] = NBTFile::Types::ByteArray.new ByteConverter.toByteString newData
  end
end
