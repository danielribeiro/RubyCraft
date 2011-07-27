#!/usr/bin/env ruby

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
    Block.new id, name, transparent, data
  end

  def self.block(id, name, transparent = false)
    @blocks ||= {}
    @blocks_by_name ||= {}
    block = Block.new id, name, transparent
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

  def self.byName(key)
    self[key]
  end

  def self.[](key)
    key = key.to_s
    return @blocks_by_name[key] if @blocks_by_name.has_key?(key)
    raise "no such name: #{key}"
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

  transparent_block 0, :air
  block 1, :stone
  block 2, :grass
  block 3, :dirt
  block 4, :cobblestone
  block 5, :planks
  transparent_block 6, :sapling
  block 7, :bedrock
  block 8, :watersource
  block 9, :water
  block 10, :lavasource
  block 11, :lava
  block 12, :sand
  block 13, :gravel
  block 14, :goldore
  block 15, :ironore
  block 16, :coal
  block 17, :log
  block 18, :leaves
  block 19, :sponge
  transparent_block 20, :glass
  block 21, :lapisore
  block 22, :lapis
  block 23, :dispenser
  block 24, :sandstone
  block 25, :note
  block 26, :bed
  transparent_block 27, :powered_rail
  transparent_block 28, :detector_rail
  block 29, :sticky_piston
  transparent_block 30, :cobweb
  transparent_block 31, :tall_grass
  transparent_block 32, :dead_shrubs
  block 33, :piston
  block 34, :piston_extension
  block 35, :wool
  transparent_block 37, :dandelion
  transparent_block 38, :rose
  transparent_block 39, :brown_mushroom
  transparent_block 40, :red_mushroom
  block 41, :gold
  block 42, :iron
  block 43, :slabs
  block 44, :slab
  block 45, :brick
  block 46, :tnt
  block 47, :bookshelf
  block 48, :mossy
  block 49, :obsidian
  transparent_block 50, :torch
  transparent_block 51, :fire
  block 52, :spawner
  block 53, :stairs
  block 54, :chest
  transparent_block 55, :redstone_wire
  block 56, :diamond_ore
  block 57, :diamond_block
  block 58, :crafting_table
  block 59, :seeds
  block 60, :farmland
  block 61, :furnace
  block 62, :burning_furnace
  transparent_block 63, :signpost
  transparent_block 64, :door
  transparent_block 65, :ladder
  transparent_block 66, :rails
  block 67, :cobblestone_stairs
  transparent_block 68, :wall_sign
  transparent_block 69, :lever
  transparent_block 70, :stone_pressure_plate
  transparent_block 71, :iron_door
  transparent_block 72, :wooden_pressure_plate
  block 73, :redstone_ore
  block 74, :glowing_redstone_ore
  transparent_block 75, :redstone_torch_off
  transparent_block 76, :redstone_torch_on
  transparent_block 77, :stone_button
  block 78, :snow
  block 79, :ice
  block 80, :snow_block
  transparent_block 81, :cactus
  block 82, :clay
  block 83, :sugar_cane
  block 84, :jukebox
  transparent_block 85, :fence
  block 86, :pumpkin
  block 87, :netherrack
  block 88, :soulsand
  block 89, :glowstone
  transparent_block 90, :portal
  block 91, :jock_o_lantern
  transparent_block 92, :cake
  transparent_block 93, :repeater_off
  transparent_block 94, :repeater_on
  block 95, :locked_chest
  transparent_block 96, :trapdoor
end

