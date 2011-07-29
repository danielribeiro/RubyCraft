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

  def defaultCompressionType
    2
  end

  def region
    chunk = compressedChunk
    offset = intBytes(2)[1..3]
    sizeCount = ((chunk.size + chunkMetaDataSize).to_f / 4096).ceil
    locations = offset + [sizeCount] + [0] * 4092
    timestamps = [0] * 4096
    metadata = intBytes(chunk.size + 1) + [defaultCompressionType]
    size = (chunk.size + chunkMetaDataSize)
    remaining = 4096 - (size % 4096)
    pad = [0] * (remaining % 4096)
    chunkdata = metadata + chunk + pad
    Region.new locations + timestamps + chunkdata
  end

  it "should desc" do
    c = region.chunk 0, 0
    blocksAre c, :stone
  end
end

