require 'rspec_helper'
require 'chunk_helper'

# Opening Chunk cube so that the chunk sizes are the ones under test.
# See chunk_helper
class RubyCraft::ChunkCube
  def chunkSide
    2
  end
end

# implementing unload for those chunks that are created directly, for testing purposes
class RubyCraft::Chunk
  def _unload
  end
end


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

  it "yields the chunk position as a Chunk object" do
    c = region.chunk 0, 0
    blocksAre c, :stone
  end

  it "can unload chunks to save space" do
    r = region
    blocksAre r.chunk(0, 0), :stone
    r.unloadChunk 0, 0
    blocksAre r.chunk(0, 0), :stone
  end

  it "can write write to a file and read back" do
    r = region
    r.chunk(0, 0).block_map { :gold }
    file = StringIO.new
    r.exportTo(file)
    bytes = stringToByteArray file.string
    newRegion = Region.new bytes
    blocksAre newRegion.chunk(0, 0), :gold
  end

  it "can view cubes of one chunk" do
    r = region
    chunks = r.instance_variable_get(:@chunks)
    r.cube(1, 1, 1, :width => 1, :length => 1, :height => 7) do |block, z, x, y|
      block.name = :wool
    end
    blocksEqual r.chunk(0, 0),
      [:stone] * h * 3 + [:stone] + [:wool] * 7
  end

  it "can view cubes of one chunk other than 0, 0" do
    r = region
    chunks = r.instance_variable_get(:@chunks)
    chunks[1][1] = createChunk
    r.cube(3, 3, 1, :width => 1, :length => 1, :height => 7) do |block, z, x, y|
      block.name = :wool
    end
    blocksEqual r.chunk(1, 1),
      [:stone] * h * 3 + [:stone] + [:wool] * 7
  end

  it "allows viewing local cube coordintates when iterating over cubes" do
    r = region
    ret = r.cube(1, 1, 1, :width => 1, :length => 1, :height => 7).
      map do |block, z, x, y|
      [z, x, y]
    end
    ret.should == [[0, 0, 0], [0, 0, 1], [0, 0, 2], [0, 0, 3], [0, 0, 4],
      [0, 0, 5], [0, 0, 6]
    ]
  end

  it "can view cubes spanning chunks with a single coordinate system" do
    r = region
    chunks = r.instance_variable_get(:@chunks)
    chunks[0][1] = createChunk
    chunks[1][1] = createChunk
    chunks[1][0] = createChunk
    chunks[2][0] = createChunk
    r.cube(1, 1, 1, :width => 3, :length => 3, :height => 7) do |block, z, x, y|
      block.name = :wool
    end
    semiWool = [:stone] + [:wool] * 7
    blocksEqual r.chunk(0, 0), [:stone] * h * 3 + semiWool
    blocksEqual r.chunk(1, 0), ([:stone] * h * 2) + semiWool * 2
    blocksEqual r.chunk(0, 1), ([:stone] * h  + semiWool) *  2
    blocksEqual r.chunk(1, 1), semiWool * area
    blocksAre r.chunk(2, 0), :stone
  end
end
