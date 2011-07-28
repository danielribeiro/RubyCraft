require 'rspec_helper'
require 'chunk'
require 'chunk_helper'

describe Region do
  include ByteConverter
  include ChunkHelper

  def compressedChunk
    chunk = createChunk
    output = StringIO.new
    name, body = chunk.export
    NBTFile.write(output, name, body)
    stringToByteArray compress(output.string)
  end

  def region
    chunk = compressedChunk

    offset = 0 # not really
    locations = [offset] + [0] * 4095
    timestamps = [0] * 4096

    Region.new bytes
  end

  it "should desc" do
    # TODO
  end
end

