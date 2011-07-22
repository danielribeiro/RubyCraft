require 'rspec_helper'
require 'chunk'
require 'block'

describe Chunk do
  include ByteConverter

  def byteArray(array)
    NBTFile::Types::ByteArray.new toByteString array
  end

  it "can use to change all block to another type" do
    data = NBTFile::Types::Compound.new
    data['HeightMap'] = byteArray [100] * 256
    data["Blocks"] = byteArray [Block[:stone].id] * 32768
    data["Data"] = byteArray [0] * 16384
    chunk = Chunk.new(["", data])
    chunk.block_map! do
      :gold
    end
    name, newData = chunk.export
    newData["Data"].value.should == toByteString([Block[:gold].id] * 32768)

  end

#  it "can iterate over planes"
#  it "can iterate over lines"
#  it "can iterate over cubes"
#  it "can iterate over blocks with data"
#  it "corrects height map"
#  it "iterate using either blockname or block full data"
#  it "maybe uses block as immutable or as mutable."
end


