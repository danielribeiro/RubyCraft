#!/usr/bin/env ruby
require 'block_type_dsl'

# A minecraft block. Its position is given by a coord[x, z, y]
class Block
  attr_accessor :transparent, :pos, :data
  attr_reader :name, :id

  def initialize(id, name, transparent, data = 0)
    @id = id
    @name = name.to_s
    @transparent = transparent
    @data = data
  end

  def clone
    self.class.new id, name, transparent, data
  end

  def is(name)
    self.name == name.to_s
  end

  #sets name along with id
  def name=(newName)
    value = newName.to_s
    @name = value
    @id = Block[value].id
  end

  #sets name along with id
  def id=(id)
    @id = id
    @name = Block.get(id).name
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

class WoolBlock < Block
  ColorValues = %w[white orange magenta light_blue yellow light_green pink gray
    light_gray cyan purple blue brown dark_green red black].map &:to_sym
  InvertedColor = Hash[ColorValues.each_with_index.to_a]

  def color=(color)
    @data = InvertedColor[color]
  end

  def color
    ColorValues[@data]
  end
end

# class methods and dsl for block
class Block
  def self.block(id, name, transparent = false)
    @blocks ||= {}
    @blocks_by_name ||= {}
    clas = if name.to_s == "wool" then WoolBlock else Block end
    block = clas.new id, name, transparent
    @blocks[id] = block
    @blocks_by_name[name.to_s] = block

  end

  def self.transparent_block(id, name)
    block id, name, true
  end

  def self.get(key)
    if @blocks.has_key?(key)
      return @blocks[key].clone
    end
    Block.new(key, "unknown(#{key})", false)
  end

  def self.of(key)
    self[key]
  end

  def self.[](key)
    key = key.to_s
    return @blocks_by_name[key].clone if @blocks_by_name.has_key?(key)
    raise "no such name: #{key}"
  end

  class_eval &BlockTypeDSL
end