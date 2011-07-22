#!/usr/bin/env ruby
# Represents a chunk data
require 'nbt_helper'
require 'byte_converter'

class Chunk
  def initialize(nbtData)
    name, @nbtBody = nbtData
  end

  # Converts all blocks on data do another type
  def block_map!(&block)
    newData = @nbtBody["Blocks"].value.bytes.map do |byte|
      ret = block.call Block.get(byte).name
      Block[ret].id
    end
    @nbtBody["Data"] = NBTFile::Types::ByteArray.new ByteConverter.toByteString newData
  end

  def export
    ["", @nbtBody]
  end
end
