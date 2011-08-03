require 'rubycraft/chunk'

module RubyCraft
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


    # unloacs the loaded chunk. Needed for memory optmization
    def _unload
      return if @chunk.nil?
      @bytes = @chunk.toNbt
      @chunk = nil
    end

    protected
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
      raise "Must be an io" if bytes.kind_of?(String)
      @bytes = bytes
      @chunks = Array.new(32) { Array.new(32) }
      readChunks bytes
    end

    def chunk(z, x)
      @chunks[z][x]
    end

    def unloadChunk(z, x)
      @chunks[z][x]._unload
    end

    def each(&block)
      @chunks.each do |line|
        line.each do |chunk|
          yield chunk
        end
      end
    end

    def cube(z, y, x, opts = {}, &block)
      c = ChunkCube.new(self, [z, y, x], opts[:width], opts[:length], opts[:height])
      return c unless block_given?
      c.each &block
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


  class ChunkCube
    include Enumerable

    # width corresponds do z, length to x, and height to y.
    def initialize(region, initialPos, width, length, height)
      @region = region
      @initialPos = initialPos
      @width = width || 1
      @length = length || 1
      @height = height || 1
    end

    def each(&block)
      z, x, y = @initialPos
      firstChunkX = x / chunkSide
      firstChunkZ = z / chunkSide
      lastChunkX = (x + @length - 1) / chunkSide
      lastChunkZ = (z + @width - 1) / chunkSide
      for j in firstChunkZ..lastChunkZ
        for i in firstChunkX..lastChunkX
          iterateOverChunk j, i, &block
        end
      end
    end

    protected
    def iterateOverChunk(j, i, &block)
      chunk = @region.chunk(j, i)
      return if chunk.nil?
      z, x, y = @initialPos
      chunk.each do |b|
        globalZ = b.z + (j * chunkSide)
        globalX = b.x + (i * chunkSide)
        if globalZ.between?(z, z + @width - 1) and
            globalX.between?(x, x + @length - 1) and
            b.y.between?(y, y + @height - 1)
          yield b, globalZ - z, globalX - x , b.y - y
        end
      end
      @region.unloadChunk(j, i)
    end

    def chunkSide
      16
    end
  end
end