require 'rspec_helper'
require 'rubycraft'
require 'chunk_helper'
describe Chunk do
  include ByteConverter
  include ChunkHelper


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
    blocksEqual chunk, [:gold] + [:stone] * (cube - 1)
  end

  it "can change data as well" do
    chunk = createChunk
    chunk.each do |block|
      block.name = :wool
      if block.pos == [0, 0, 0]
        block.data = 5
      else
        block.data = 4
      end
    end
    blocks = [Block[:wool].id] * cube
    chunkName, newData = chunk.export
    newData["Level"]["Blocks"].value.should == toByteString(blocks)
    newData["Level"]["Data"].value.
      should == toByteString([(4 << 4) + 5] + [(4 << 4) + 4] * (datacube - 1))
  end

  it "can read the data from the levels" do
    chunk = createChunk([(2 << 4) + 1] * datacube)
    data = chunk.map { |b| b.data }
    data.should == [1, 2] * datacube
  end

  it "corrects the height attribute when you export" do
    chunk = createChunk
    chunk.each do |block|
      if block.y > 0
        block.name = :air
      end
    end
    blocksEqual chunk, ([:stone] + [:air] * (h - 1)) * area
    chunkName, newData = chunk.export
    newData["Level"]["HeightMap"].value.should == toByteString([1] * area)
  end
end


