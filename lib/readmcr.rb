#!/usr/bin/env ruby
require 'mnedit'
puts "Starting"
#reg = '/home/daniel/.minecraft/saves/LowDirt/region/r.0.0.mcr'
reg = '/home/daniel/.minecraft/saves/newone/region/r.0.-1.mcr'
Region.new(reg).readChunk 0, 31
#Region.new(reg).printspecs



#Levels are:
#  [["Data", NBTFile::Types::ByteArray], ["Entities", NBTFile::Types::List],
#   ["LastUpdate", NBTFile::Types::Long], ["xPos", NBTFile::Types::Int],
#    ["zPos", NBTFile::Types::Int], ["TileEntities", NBTFile::Types::List],
#     ["TerrainPopulated", NBTFile::Types::Byte],
#      ["SkyLight", NBTFile::Types::ByteArray],
#       ["HeightMap", NBTFile::Types::ByteArray],
#        ["BlockLight", NBTFile::Types::ByteArray],
#        ["Blocks", NBTFile::Types::ByteArray]]
