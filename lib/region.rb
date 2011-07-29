require 'chunk'

class LazyChunkDelegate
  include ByteConverter
  include ZlibHelper

  def initialize(bytes)
    @bytes = bytes
    @chunk = nil
  end

  def each(&block)
     _getchunk.each &block
  end
  
  def block_map(&block)
    _getchunk.block_map &block
  end
  def block_type_map(&block)
    _getchunk.block_type_map &block
  end

  def [](z, x, y)
    _getchunk[z, x, y]
  end

  def []=(z, x, y, value)
    _getchunk[z, x, y] = value
  end

  def export
    _getchunk.export
  end

  def toNbt
    return @bytes if @chunk.nil?
    @chunk.toNbt
  end


  private
  def _getchunk
    if @chunk.nil?
      @chunk = Chunk.fromNbt @bytes
    end
    @chunk
  end

end

# Enumerable over chunks
class Region
  include Enumerable
  include ByteConverter
  include ZlibHelper
  
  class RegionWritter
    def initialize(io)
      @io = io
    end

    def pad(count, value = 0)
      self << Array.new(count) { value }
    end

    def <<(o)
      input = o.kind_of?(Array) ? o : [o]
      @io <<  ByteConverter.toByteString(input)
    end

    def close
      @io.close
    end
  end

  def self.fromFile(filename)
    new ByteConverter.stringToByteArray IO.read filename
  end

  def initialize(bytes)
    @bytes = bytes
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
    bytes[0..(blockSize - 1)].each_slice(4).each_with_index do |ar, i|
      offset = bytesToInt [0] + ar[0..-2]
      count = ar.last
      if count > 0
        @chunks[i / 32][i % 32 ] = readChunk(offset, bytes)
      end
    end
  end

  def readChunk(offset, bytes)
    o = offset * blockSize
    bytecount = bytesToInt bytes[o..(o + 4)]
    o += 5
    nbtBytes = bytes[o..(o + bytecount - 2)]
    LazyChunkDelegate.new nbtBytes
  end

  def exportTo(io)
    output = RegionWritter.new io
    chunks = getChunks
    writeChunkOffsets output, chunks
    output.pad blockSize, dummytimestamp
    writeChunks output, chunks
    output.close
  end

  def exportToFile(filename)
    File.open(filename, "wb") { |f| exportTo f }
  end

  protected
  def chunkSize(chunk)
    chunk.size + chunkMetaDataSize
  end

  def chunkBlocks(chunk)
    ((chunkSize chunk).to_f / blockSize).ceil
  end

  def writeChunks(output, chunks)
    for chunk in chunks
      next if chunk.nil?
      output << intBytes(chunk.size + 1)
      output << defaultCompressionType
      output << chunk
      remaining = blockSize - chunkSize(chunk)
      output.pad remaining % blockSize
    end
  end

  def writeChunkOffsets(output, chunks)
    lastVacantPosition = 2
    for chunk in chunks
      if chunk
        sizeCount = chunkBlocks chunk
        output << intBytes(lastVacantPosition)[1..3]
        output << sizeCount
        lastVacantPosition += sizeCount
      else
        output.pad 4
      end
    end
  end

  def getChunks
    map do |chunk|
      if chunk.nil?
        nil
      else
        chunk.toNbt
      end
    end
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

  def blockSize
    4096
  end

end
