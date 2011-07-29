require 'byte_converter'
require 'chunk'
require 'zlib'

class Region
  include ByteConverter
  include ZlibHelper

  def initialize(bytes)
    @bytes = bytes
    @chunks = Array.new(32) { Array.new(32) }
    readChunks
  end

  def chunk(x, z)
    @chunks[z][x]
  end

  def readChunks
    @bytes[0..4095].each_slice(4).each_with_index do |ar, i|
      offset = bytesToInt [0] + ar[0..-2]
      count = ar.last
      if count > 0
        @chunks[i / 32][i % 32 ] = readChunk(offset)
      end
    end
  end

  def readChunk(offset)
    o = offset * 4096
    bytecount = bytesToInt @bytes[o..(o + 4)]
    o += 5
    nbtBytes = @bytes[o..(o + bytecount - 2)]
    Chunk.new readnbt nbtBytes
  end


  def writeChunks
    chunkMetaDataSize = 5
    dummytimestamp = 0
    newBytes = []
    lastVacantPosition = 2
    for chunk in chunks
      if chunk
        offset = lastVacantPosition
        sizeCount = ((chunk.size + chunkMetaDataSize).to_f / 4096).ceil
        lastVacantPosition += sizeCount
        concat newBytes, intBytes(offset)[1..3]
        newBytes << sizeCount
      else
        pad newBytes, 4
      end
    end
    defaultCompressionType = 2
    pad newBytes, 4096, dummytimestamp
    for chunk in chunks
      next if chunk.nil?
      concat newBytes, intBytes(chunk.size + 1)
      newBytes << defaultCompressionType
      concat newBytes, chunk
      size = (chunk.size + chunkMetaDataSize)
      remaining = 4096 - (size % 4096)
      pad newBytes, remaining % 4096
    end
    File.open(@file, "wb") do |f|
      f << newBytes.pack("C*")
    end
  end



  # deprecated
  def doconvertChunk
    nbtdata = readnbt nbtBytes
    c = Chunk.new nbtdata
    c.each do |b|
      if b.y == 63
        b.name = :wool
        b.data = (b.x + b.z) % 16
      end
    end
    output = StringIO.new
    name, body = c.export
    NBTFile.write(output, name, body)
    out = stringToByteArray compress(output.string)
    return out
  end

  protected
  def readnbt(bytes)
    NBTFile.read  stringToIo decompress(toByteString(bytes))
  end

  # deprecated
  def write
    File.open(@file, "wb") do |f|
      f << bytes.pack("C*")
    end
    self
  end

end
