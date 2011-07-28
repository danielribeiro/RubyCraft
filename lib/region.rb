require 'byte_converter'
require 'chunk'
require 'zlib'

class Region
  include ByteConverter

  attr_accessor :bytes
  attr_accessor :file

  def initialize(file)
    @bytes = stringToByteArray IO.read(file)
    @file = file
  end

  def write
    File.open(@file, "wb") do |f|
      f << bytes.pack("C*")
    end
    self
  end

  def convertChunks(&block)
    chunkMetaDataSize = 5
    dummytimestamp = 0
    chunks = []
    counter = PlaneCounter.new
    bytes[0..4095].each_slice(4) do |ar|
      offset = bytesToInt [0] + ar[0..-2]
      count = ar.last
      if count > 0
        chunks << convertChunk(offset, counter.pos, &block)
      else
        chunks << nil
      end
      counter.inc
    end
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

  def convertChunk(offset, pos, &block)
    o = offset * 4096
    bytecount = bytesToInt bytes[o..(o + 4)]
    o += 5
    nbtBytes = bytes[o..(o + bytecount - 2)]
    offset = o
    return nbtBytes unless block_given? and block.call(pos)
    puts "converting: #{pos.inspect}"
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

  def getNbt(x, z)
    o = 4 * (x + z * 32)
    offset = bytesToInt [0] + bytes[o..(o + 2)]
    o = offset * 4096
    bytecount = bytesToInt bytes[o..(o + 4)]
    o += 5
    nbtBytes = bytes[o..(o + bytecount - 2)]
    readnbt nbtBytes
  end


  def change(x, z)
    o = 4 * (x + z * 32)
    offset = bytesToInt [0] + bytes[o..(o + 2)]
    o = offset * 4096
    bytecount = bytesToInt bytes[o..(o + 4)]
    o += 5
    nbtBytes = bytes[o..(o + bytecount - 2)]
    offset = o
    name, body = readnbt nbtBytes
    blocks = body['Level']['Blocks']
    newarray = blocks.value.bytes.map do |b|
      8
    end
    body['Level']['Blocks'] = NBTFile::Types::ByteArray.new newarray.pack("C*")
    output = StringIO.new
    NBTFile.write(output, name, body)
    @bytes[offset..(offset + bytecount - 2)] = stringToByteArray compress(output.string)
    self
  end

  protected
  def readnbt(bytes)
    NBTFile.read  stringToIo Zlib::Inflate.inflate(toByteString(bytes))
  end

  def compress(str)
    Zlib::Deflate.deflate(str)
  end

end
