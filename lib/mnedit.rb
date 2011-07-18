#!/usr/bin/env ruby
require 'rubygems'
require 'active_support'
require 'nbtfile'
require 'stringio'
require 'zlib'
require 'block'

class Integer
  def bytes
    [self >> 24, (self >> 16) & 0xFF, (self >> 8) & 0xFF, self & 0xFF]
  end
end

module ArrayExtension
  def add_all(enum)
    for i in enum
      self << i
    end
    self
  end

  # To be used when the array is used as a byte array
  def toIo
    io = StringIO.new
    io.write self.pack('C*')
    io.rewind
    io
  end
end

class Array
  include ArrayExtension
end

class String
  # To be used when string is used as a byte array
  def toIo
    byteArray.toIo
  end

  def byteArray
    bytes.to_a
  end
end

class NBTFile::Private::Tokenizer
  def initialize(io)
    @gz = io
    @state = NBTFile::Private::TopTokenizerState.new()
  end
end

class NBTFile::Emitter
  def initialize(stream)
    @gz = stream
    @state = NBTFile::Private::TopEmitterState.new()
  end
end

class PlaneCounter
  attr_reader :x, :z
  def initialize
    @x = 0
    @z = 0
  end

  def inc
    @x += 1
    if @x == 32
      @x = 0
      @z += 1
    end
    pos
  end

  def pos
    [@x, @z]
  end

end

class ChunkCounter
  attr_reader :x, :y, :z

  def initialize
    @y = 0
    @z = 0
    @x = 0
  end

  def inc
    @y += 1
    if @y == 128
      @y = 0
      @z += 1
    end
    if @z == 16
      @z = 0
      @x += 1
    end
    pos
  end

  def pos
    [@y, @z, @x]
  end

end

class Region
  attr_accessor :bytes

  def initialize(file)
    @bytes = IO.read(file).byteArray
    @file = file
  end

  def write
    File.open(@file, "wb") do |f|
      f << bytes.pack("C*")
    end
    self
  end

  def printspecs
    counter = PlaneCounter.new
    bytes[0..4095].each_slice(4) do |ar|
      p ar
      offset = bytesToInt [0] + ar[0..-2]
      count = ar.last
      x, y = counter.pos
      puts "[#{x}, #{y}] : #{offset}, count = #{count}"
      counter.inc
    end
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
        newBytes.add_all offset.bytes[1..3]
        newBytes << sizeCount
      else
        pad newBytes, 4
      end
    end
    defaultCompressionType = 2
    pad newBytes, 4096, dummytimestamp
    for chunk in chunks
      next if chunk.nil?
      newBytes.add_all((chunk.size + 1).bytes)
      newBytes << defaultCompressionType
      newBytes.add_all chunk
      size = (chunk.size + chunkMetaDataSize)
      remaining = 4096 - (size % 4096)
      pad newBytes, remaining % 4096
    end
    File.open(@file, "wb") do |f|
      f << newBytes.pack("C*")
    end
  end

  def pad(array, count, value = 0)
    count.times do
      array << value
    end
    array
  end

  def convertChunk(offset, pos, &block)
    o = offset * 4096
    bytecount = bytesToInt bytes[o..(o + 4)]
    o += 5
    nbtBytes = bytes[o..(o + bytecount - 2)]
    offset = o
    return nbtBytes unless block_given? and block.call(pos)
    puts "converting: #{pos.inspect}"
    name, body = readnbt nbtBytes
    blocks = body['Level']['Blocks']
    counter = ChunkCounter.new
    newarray = blocks.value.bytes.map do |b|
      ret = if counter.y == 63
        35
      else
        b
      end
      counter.inc
      ret
    end
    body['Level']['Blocks'] = NBTFile::Types::ByteArray.new newarray.pack("C*")
    counter = ChunkCounter.new
    data = body['Level']['Data']
    dataArray = data.value.bytes.map do |b|
      head = b >> 4
      tail = b & 0xF
      tailpos = counter.pos
      counter.inc
      headpos = counter.pos
      newHead = if headpos.first == 63
        y, z, x = headpos
        (x + z) % 16
      else
        head
      end
      newTail = if tailpos.first == 63
        12
        y, z, x = tailpos
        (x + z) % 16
      else
        tail
      end
      counter.inc
      (newHead << 4) + newTail
    end
    body['Level']['Data'] = NBTFile::Types::ByteArray.new dataArray.pack("C*")

    output = StringIO.new
    NBTFile.write(output, name, body)
    out = compress(output.string).byteArray
    return out
  end

  def readChunk(x, z)
    o = 4 * (x + z * 32)
    offset = bytesToInt [0] + bytes[o..(o + 2)]
    puts "Its sector count is  #{bytes[o + 3]}"
    puts "the offset is: #{offset}"
    o = offset * 4096
    bytecount = bytesToInt bytes[o..(o + 4)]
    puts "It has size: #{bytecount}"
    o += 5
    nbtBytes = bytes[o..(o + bytecount - 2)]
    offset = o
    printNbt(nbtBytes)
  end

  def printNbt(nbtBytes)
    name, body = readnbt nbtBytes
    blocks = body['Level']['Blocks'].value.bytes.to_a
    datavalues = body['Level']['Data'].value.bytes.to_a
    
    counter = ChunkCounter.new
    puts "-> Blocks x Data"
    index = 0
    while index < 32768
      b = blocks[index]
      name = Block.get(b).name
      data = datavalues[index / 2]
      datavalue = if index % 2 == 0
        data & 0xF
      else
        data >> 4
      end
      altData = if index % 2 == 1
        data & 0xF
      else
        data >> 4
      end
      puts "#{counter.pos.inspect}: #{name}, data = #{datavalue}, altdata = #{altData}"
      counter.inc
      index += 1
    end

    counter = ChunkCounter.new
    data = body['Level']['Data']
    data.value.bytes.each do |b|
      head = b >> 16
      tail = b & 0xFFFF
      puts "data At #{counter.pos.inspect} is #{head}"
      counter.inc
      puts "data At #{counter.pos.inspect} is #{tail}"
      counter.inc
      puts "!!!the full data is #{b}" if b != 0
    end

    puts "-> Height map"
    heightmap = body['Level']['HeightMap']
    x = 0
    z = 0
    heightmap.value.bytes.each do |h|
      puts "At [#{x}, #{z}]: #{h}"
      x += 1
      if x == 16
        z += 1
        x = 0
      end
    end

    puts "-> LastUpdate: #{body['Level']['LastUpdate'].value }"
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
    @bytes[offset..(offset + bytecount - 2)] = compress(output.string).byteArray
    self
  end

  protected
  def bytesToInt(array)
    array.pack('C*').unpack("N").first
  end

  def readnbt(bytes)
    NBTFile.read Zlib::Inflate.inflate(bytes.toIo.read).toIo
  end

  def compress(str)
    Zlib::Deflate.deflate(str)
  end

end
