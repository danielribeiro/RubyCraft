RubyCraft
==============

RubyCraft is a simple library for manipulating [Minecraft](http://www.minecraft.net/)
region files.

Region files are files with the mcr extension on the region folder of a save folder. The
save folders are located below the saves folder of the minecraft data folder (for
instance, on Linux it is ~/.minecraft/saves/$SAVENAME/region, and on mac it is
~/Library/Application Support/minecraft/$SAVENAME/region). More about save folders
[here](http://www.minecraftwiki.net/wiki/Tutorials/Minecraft_Help_FAQ#Common_fixes).


Quick Example
=============
        filename = " ~/.minecraft/saves/$SAVENAME/region/r.0.0.mcr"
        r = Region.fromFile(filename)
        r.chunk(0, 0).block_map { :gold }
        r.exportToFile filename

For more examples, check the [examples](https://github.com/danielribeiro/RubyCraft/tree/master/examples) folder



Dependencies
=============
[Nbtfile](http://github.com/mental/nbtfile)

Meta
----

Created by Daniel Ribeiro

Released under the MIT License: http://www.opensource.org/licenses/mit-license.php

http://github.com/danielribeiro/RubyCraft
