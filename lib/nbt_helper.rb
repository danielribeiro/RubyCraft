#!/usr/bin/env ruby
require 'nbtfile'
# Patching nbtfile clases so that they don't gzip/ungzip incorrectly the zlib bytes from
#mcr files. Use Zlib::Inflate and  Zlib::Inflate.inflate and Zlib::Deflate.deflate
#for this

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
