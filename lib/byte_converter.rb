#!/usr/bin/env ruby
# Will make into function the following monkey patches:

#class Integer
#  def bytes
#    [self >> 24, (self >> 16) & 0xFF, (self >> 8) & 0xFF, self & 0xFF]
#  end
#end
#
#module ArrayExtension
#  def add_all(enum)
#    for i in enum
#      self << i
#    end
#    self
#  end
#
#  # To be used when the array is used as a byte array
#  def toIo
#    io = StringIO.new
#    io.write self.pack('C*')
#    io.rewind
#    io
#  end
#end
#
#class Array
#  include ArrayExtension
#end
#
#class String
#  # To be used when string is used as a byte array
#  def toIo
#    byteArray.toIo
#  end
#
#  def byteArray
#    bytes.to_a
#  end
#end

module ByteConverter
  def toByteString(array)
    array.pack('C*')
  end
  extend self
end