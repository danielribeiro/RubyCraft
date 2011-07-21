#!/usr/bin/env ruby
# Represents a chunk data
require 'nbt_helper'
require 'byte_converter'

class Chunk
  def initialize(nbtBody)
    @nbtBody = nbtBody
  end
end
