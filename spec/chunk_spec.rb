require 'rspec_helper'
require 'chunk'
require 'block'

describe Chunk do
  include ByteConverter

  def byteArray(array)
    NBTFile::Types::ByteArray.new toByteString array
  end

  it "should desc" do
    data = NBTFile::Types::Compound.new
    data['HeightMap'] = byteArray [100] * 256
    data["Blocks"] = byteArray [Block[:stone].id] * 32768
    chunk = Chunk.new(data)

  end
end

