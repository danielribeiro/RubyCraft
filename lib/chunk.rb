# Represents a chunk data
require 'nbt_helper'
require 'byte_converter'
require 'block'
require 'matrix3d'

# Chunks are enumerable over blocks
class Chunk
  include Enumerable
  include ZlibHelper

  Width = 16
  Length = 16
  Height = 128

  def self.fromNbt(bytes)
    new NbtHelper.fromNbt bytes
  end

  def initialize(nbtData)
    name, @nbtBody = nbtData
    bytes = level["Blocks"].value.bytes
    @blocks = matrixfromBytes bytes
    @blocks.each_triple_index do |b, z, x, y|
      b.pos = [z, x, y]
    end
    data = level["Data"].value.bytes.to_a
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
    level["Data"] = byteArray exportLevelData
    level["Blocks"] = byteArray @blocks.map { |b| b.id }
    level["HeightMap"] = byteArray exportHeightMap
    ["", @nbtBody]
  end

  def toNbt
    NbtHelper.toBytes export
  end

  protected
  def exportHeightMap
    zwidth, xwidth, ywidth = @blocks.bounds
    matrix = Array.new(zwidth) { Array.new(xwidth) { 1 }}
    @blocks.each_triple_index do |b, z, x, y|
      unless b.transparent
        matrix[z][x] = [matrix[z][x], y + 1].max
      end
    end
    ret = []
    matrix.each do |line|
      line.each do |height|
        ret << height
      end
    end
    ret
  end

  def level
    @nbtBody["Level"]
  end

  def exportLevelData
    data = []
    @blocks.each_with_index do |b, i|
      if i % 2 == 0
        data << b.data
      else
        data[i / 2] += (b.data << 4)
      end
    end
    data
  end

  def byteArray(data)
    NBTFile::Types::ByteArray.new ByteConverter.toByteString(data)
  end

  def matrixfromBytes(bytes)
    Matrix3d.new(Width, Length, Height).fromArray bytes.map {|byte| Block.get(byte) }
  end


end
