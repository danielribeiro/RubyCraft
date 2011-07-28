# Opening Chunk so that we can test with smaller data set (2x2x8 per chunk),
#instead of 16x16x128 of regular minecraft chunk
class Chunk
  def matrixfromBytes(bytes)
    Matrix3d.new(2, 2, 8).fromArray bytes.map {|byte| Block.get(byte) }
  end
end

module ChunkHelper
  # height of the test chunk
  def h
    8
  end

  # the area of a horizontal section (how many blocks that have the same y)
  def area
    4
  end

  def cube
    h * area
  end

  # Data cube has half as much bytes
  def datacube
    cube / 2
  end

  def byteArray(array)
    NBTFile::Types::ByteArray.new toByteString array
  end

  def createChunk(blockdata = [0] * datacube, blocks = [Block[:stone].id] * cube)
    nbt = NBTFile::Types::Compound.new
    nbt["Level"] = NBTFile::Types::Compound.new
    level = nbt["Level"]
    level['HeightMap'] = byteArray [h] * area
    level["Blocks"] = byteArray blocks
    level["Data"] = byteArray blockdata
    Chunk.new(["", nbt])
  end
end