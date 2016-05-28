# RubyCraft


RubyCraft is a simple library for manipulating [Minecraft](http://www.minecraft.net/)
region files. Installation is as simple as:

    $ gem install rubycraft

Region files are files with the mcr extension on the region folder of a save folder. The
save folders are located below the saves folder of the minecraft data folder (for
instance, on Linux it is ~/.minecraft/saves/$SAVENAME/region, and on mac it is
~/Library/Application Support/minecraft/$SAVENAME/region). More about save folders
[here](http://www.minecraftwiki.net/wiki/Tutorials/Minecraft_Help_FAQ#Common_fixes).


## What can be done with this?
<a href="http://metaphysicaldeveloper.wordpress.com/2011/07/31/hacking-a-gnuplot-into-minecraft/" target="_blank">![](https://raw.github.com/danielribeiro/RubyCraft/master/images/plottingOverview.png)]</a>



## Quick Example
```ruby
filename = " ~/.minecraft/saves/$SAVENAME/region/r.0.0.mcr"
r = Region.fromFile(filename)
r.chunk(0, 0).block_map { :gold }
r.exportToFile filename
```

For more examples, check the
[examples](https://github.com/danielribeiro/RubyCraft/tree/master/examples) folder.

## Regions

When getting many chunks from Region#chunk method, don't forget to invoke Region#unloadChunk(z,
x). This way the chunk will not occupy memory.

Alternatively you can use the Region#cube method. Example

```ruby
r = Region.fromFile(filename)
c = r.cube(0, 0, 0, :width => 50, :length => 50, :height => 128)
c.each do |block, z, x, y|
       block.name = :wool
       block.color = :orange
end
```

It receives the z, x, y of the origin point of the cube, and its respective width, length
and height. The chunk load/unload is abstracted way on this interface. The cube can
receive a block, or it will return an Enumerable that iterates over the blocks of the
cube. The proc receives four arguments: the block, and its relative coordinates to the
cube's origin point.

## Chunks

Chunks are both enumerable and indexable:

```ruby
chunk[0, 0, 0].name = :gold
chunk.each { |block| block.name = :gold }
```


Note that chunks have size 16x16x128 (width, length, height). Usually you don't create
chunks directly, but get them through Region#chunk method.

##Blocks

Blocks have 3 attributes: block_type, pos and data. [Block type](https://github.com/danielribeiro/RubyCraft/blob/master/lib/rubycraft/block_type.rb) tells the name, id and
transparency (boolean) of the block. The pos attribute indicates the position of the block
inside its chunk, and data is the integer [data
value](http://www.minecraftwiki.net/wiki/Data_values).

Id is not usually accessed directly, as the name attribute provides a more friendly
interface. For wool blocks, changing the color directly is also possible in a more
friendly way.

```ruby
block.name = :wool
block.color = :purple
p block.color
```


## Meta

Created by [Daniel Ribeiro](http://metaphysicaldeveloper.wordpress.com/about-me)

Released under the MIT License: http://www.opensource.org/licenses/mit-license.php

http://github.com/danielribeiro/RubyCraft
