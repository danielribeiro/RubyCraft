require 'rspec_helper'
require 'chunk'
require 'chunk_helper'
require 'region'

describe Region do
  include ByteConverter
  include ChunkHelper
  include ZlibHelper

  def compressedChunk
    chunk = createChunk
    output = StringIO.new
    name, body = chunk.export
    NBTFile.write(output, name, body)
    stringToByteArray compress(output.string)
  end


  def chunkMetaDataSize
    5
  end

  def region
    chunk = compressedChunk
    offset = intBytes(2)[1..3]
    sizeCount = ((chunk.size + chunkMetaDataSize).to_f / 4096).ceil
    locations = offset + [sizeCount] + [0] * 4092
    timestamps = [0] * 4096
    Region.new nil
  end

  it "should desc" do
    region
  end
end

