require 'rspec_helper'
require 'chunk'
require 'block'

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

  it "can use to change all block to another type" do
    chunk = createChunk
    chunk.block_map do
      :gold
    end
    name, newData = chunk.export
    newData["Level"]["Blocks"].value.should == toByteString([Block[:gold].id] * 32)
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
    name, newData = chunk.export
    newData["Level"]["Blocks"].value.should == toByteString([Block[:gold].id] * 32)
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
    name, newData = chunk.export
    newData["Level"]["Blocks"].value.should == toByteString([Block[:gold].id] * 32)
  end

  #  it "can iterate over planes"
  #  it "can iterate over lines"
  #  it "can iterate over cubes"
  #  it "can iterate over blocks with data"
  #  it "corrects height map"
  #  it "iterate using either blockname or block full data"
  #  it "maybe uses block as immutable or as mutable."
end


