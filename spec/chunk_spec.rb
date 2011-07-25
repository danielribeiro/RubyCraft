require 'rspec_helper'
require 'chunk'
require 'block'

# Opening Chunk so that we can test with smaller data set (2x2x8 per chunk),
#instead of 16x16x128 of regular minecraft chunk
class Chunk
  def initialize(nbtData)
    name, @nbtBody = nbtData
    bytes = @nbtBody["Level"]["Blocks"].value.bytes
    @blocks = Matrix3d.new(2, 2, 8).fromArray bytes.map {|byte| Block.get(byte) }
    @blocks.each_triple_index do |b, pos|
      next if b.nil?
      b.pos = pos
    end
  end
end

describe Chunk do
  include ByteConverter

  def byteArray(array)
    NBTFile::Types::ByteArray.new toByteString array
  end

  def createChunk
    level = NBTFile::Types::Compound.new
    level["Level"] = NBTFile::Types::Compound.new
    data = level["Level"]
    data['HeightMap'] = byteArray [100] * 256
    data["Blocks"] = byteArray [Block[:stone].id] * 32
    data["Data"] = byteArray [0] * 16
    Chunk.new(["", level])
  end

  def blocksAre(chunk, name)
    blocksEqual chunk, [name] * 32
  end

  def blocksEqual(chunk, nameArray)
    blocks = nameArray.map { |name| Block[name].id }
    chunkName, newData = chunk.export
    newData["Level"]["Blocks"].value.should == toByteString(blocks)
  end

  it "can use to change all block to another type" do
    chunk = createChunk
    chunk.block_map { :gold }
    blocksAre chunk, :gold
  end

  it "can iterate over all blocks and change them" do
    chunk = createChunk
    chunk.block_map do |block|
      if block.is :stone
        :gold
      else
        :air
      end
    end
    blocksAre chunk, :gold
  end

  it "can iterate over all blocks while only getting their name as symbol" do
    chunk = createChunk
    chunk.block_type_map do |blockname|
      if blockname == :stone
        :gold
      else
        :air
      end
    end
    blocksAre chunk, :gold
  end

  it "can iterate over blocks with position data" do
    chunk = createChunk
    heights = []
    chunk.block_map do |block|
      heights << block.pos if heights.length < 5
      block.name
    end
    heights.should == [[0, 0, 0], [0, 0, 1], [0, 0, 2], [0, 0, 3], [0, 0, 4]]
  end

  it "is mutable. Change the blocks on the each method, change export" do
    chunk = createChunk
    chunk.each do |block|
      block.name = :gold
    end
    blocksAre chunk, :gold
  end

  it "can change a block given by x, z, y" do
    chunk = createChunk
    chunk[0, 0, 0].name = :gold
    blocksEqual chunk, [:gold] + [:stone] * 31
  end

  #  it "can iterate over planes"
  #  it "can iterate over lines"
  #  it "can iterate over cubes"
  #  it "can iterate over blocks with data"
  #  it "corrects height map"
  #  it "iterate using either blockname or block full data"
  #  it "maybe uses block as immutable or as mutable."
end


