#!/usr/bin/env ruby
require 'block_type'

# A minecraft block. Its position is given by a coord[x, z, y]
class Block
  attr_accessor :block_type, :pos, :data

  ColorValues = %w[white orange magenta light_blue yellow light_green pink gray
    light_gray cyan purple blue brown dark_green red black].map &:to_sym
  InvertedColor = Hash[ColorValues.each_with_index.to_a]


  def self.get(key)
    new BlockType.get key
  end

  def self.of(key)
    self[key]
  end

  def self.[](key)
    new BlockType[key]
  end


  def color=(color)
    @data = InvertedColor[color]
  end

  def color
    ColorValues[@data]
  end

  def initialize(blockType, data = 0)
    @blockType = blockType
    @data = 0
  end

  def is(name)
    self.name == name.to_s
  end

  def name
    @blockType.name
  end

  def id
    @blockType.id
  end

  def transparent
    @blockType.transparent
  end

  #sets name along with id
  def name=(newName)
    return if name == newName.to_s
    @blockType = BlockType[newName]
  end

  #sets name along with id
  def id=(id)
    return if id == id
    @blockType = BlockType.get id
  end

  def y
    pos[2]
  end

  def z
    pos[1]
  end

  def x
    pos[0]
  end
end

