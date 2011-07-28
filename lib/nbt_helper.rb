#!/usr/bin/env ruby
require 'nbtfile'
require 'zlib'
# Patching nbtfile clases so that they don't gzip/ungzip incorrectly the zlib bytes from
#mcr files. Use the methods from ZlibHelper
class NBTFile::Private::Tokenizer
  def initialize(io)
    @gz = io
    @state = NBTFile::Private::TopTokenizerState.new
  end
end

class NBTFile::Emitter
  def initialize(stream)
    @gz = stream
    @state = NBTFile::Private::TopEmitterState.new
  end
end

module ZlibHelper
  def compress(str)
    Zlib::Deflate.deflate(str)
  end

  def decompress(str)
    Zlib::Inflate.inflate(str)
  end
  extend self
end