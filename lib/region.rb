require 'byte_converter'
require 'chunk'
require 'zlib'

# Enumerable over chunks
class Region
  include Enumerable
  include ByteConverter
  include ZlibHelper

  def initialize(bytes)
    @chunks = Array.new(32) { Array.new(32) }
    readChunks bytes
  end

  def chunk(x, z)
    @chunks[z][x]
  end

  def each(&block)
    @chunks.each do |line|
      line.each do |chunk|
        yield chunk
      end
    end
  end

  def readChunks(bytes)
    bytes[0..4095].each_slice(4).each_with_index do |ar, i|
      offset = bytesToInt [0] + ar[0..-2]
      count = ar.last
      if count > 0
        @chunks[i / 32][i % 32 ] = readChunk(offset, bytes)
      end
    end
  end

  def readChunk(offset, bytes)
    o = offset * 4096
    bytecount = bytesToInt bytes[o..(o + 4)]
    o += 5
    nbtBytes = bytes[o..(o + bytecount - 2)]
    Chunk.new readnbt nbtBytes
  end

  def exportTo(io)
    newBytes = []
    lastVacantPosition = 2
    chunks = getChunks
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
    io << newBytes.pack("C*")
  end

  protected
  def getChunks
    map do |chunk|
      unless chunk.nil?
        output = StringIO.new
        name, body = chunk.export
        NBTFile.write(output, name, body)
        stringToByteArray compress output.string
      else
        nil
      end
    end
  end

  def readnbt(bytes)
    NBTFile.read stringToIo decompress toByteString bytes
  end

  def chunkMetaDataSize
    5
  end

  def defaultCompressionType
    2
  end

  def dummytimestamp
    0
  end

end
