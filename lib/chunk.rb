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
      next if b.nil?
      b.pos = pos
    end
  end

  # Converts all blocks on data do another type
  def block_map(&block)
    each do |b|
      b.name = yield b
    end
  end

  def block_type_map(&block)
    each do |b|
      b.name = yield b.name.to_sym
    end
  end

  def export
    newData = @blocks.select { |i| i }. map { |b| b.id } # fixme mock this select on the test
    @nbtBody["Level"]["Blocks"] = NBTFile::Types::ByteArray.new ByteConverter.toByteString newData
    ["", @nbtBody]
  end

  def each(&block)
    @blocks.each &block
  end

end
