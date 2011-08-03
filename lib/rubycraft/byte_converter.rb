require 'stringio'

module RubyCraft
  # Utils for manipulating bytes back and forth as strings, strings and numbers
  module ByteConverter
    def toByteString(array)
      array.pack('C*')
    end

    def intBytes(i)
      [i >> 24, (i >> 16) & 0xFF, (i >> 8) & 0xFF, i & 0xFF]
    end

    def stringToByteArray(str)
      str.bytes.to_a
    end

    def arrayToIO(arr)
      io = StringIO.new
      io.write toByteString arr
      io.rewind
      io
    end

    def stringToIo(str)
      arrayToIO stringToByteArray(str)
    end

    def concat(array, enum)
      for i in enum
        array << i
      end
    end

    def bytesToInt(array)
      array.pack('C*').unpack("N").first
    end

    def pad(array, count, value = 0)
      count.times do
        array << value
      end
      array
    end

    extend self
  end
end