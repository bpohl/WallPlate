# WallPlate

**OpenSCAD Library for drawing Electrical Wall Plates**

Electrical wall plates are easy to buy so long as the devices you are trying to cover are a modern standard or not in some strange order in a muli-gang box.  [Decora](#Decora)-style devices are usually the way to go, but what if the device is old or just unusual.

This library can generate wall plates of standard sizes with any number of devices (gangs).  It can also create plates of arbitrary size and attributes to be the base of a custom design.

## Installation

Cloning the repository on to a local disk is enough to use the library.  If new wall plate files are kept in the top directory of the worktree then OpenSCAD should be able to find all the pieces.  Otherwise, the folder [`WallPlate`](./WallPlate) can be copied to any place in the [`OPENSCADPATH`](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Libraries#Setting_OPENSCADPATH).

## Usage

### Getting Started

The only library required to make something happen is the Generator.

        /* Base Generator library */
        use <WallPlate/WallPlate_Generator.scad>;

This will also include the `WallPlate/WallPlate_Dimensions.scad` library which contains, not surprisingly, the standard dimensions for the various sized plates along with bunches of constants and functions for handling them and the `$dimensions` vector.

To add the modules that generate the particular devices, their libraries need to be included by name.

        /* Device specific libraries */
        use <WallPlate/WallPlate_Decora.scad>;
        use <WallPlate/WallPlate_ToggleSwitch.scad>;

Just to be lazy, everything needed to make a wall plate, including the Generator, can be brought in with one `include`.

        /* Just include all the Devices */
        include <WallPlate/WallPlate_IncludeAll.scad>;

### Making a simple plate

To make a plate using the included dimensions and devices, `include` the required libraries and use the `WallPlate()` module.

        use <WallPlate/WallPlate_Generator.scad>;
        use <WallPlate/WallPlate_Decora.scad>;
        use <WallPlate/WallPlate_Duplex.scad>;
        
        WallPlate(){
            Decora();
            Decora();
            Duplex();
        }

![](README.images/DecDecDup.png)

To change the order of the devices on the plate, just change their order in the list.

        WallPlate(){
            Decora();
            Duplex();
            Decora();
        }

![](README.images/DecDupDec.png)

### Changing the plate size

The `WallPlate()` module takes only one parameter, `dimensions`, which is a defined vector of 6 values.  (See the `DimensionsVector()` module.)  There are four predefined sizes, each returned by a "getter function".

* DefaultStandardDimensions() 
* DefaultMidwayDimensions()  
* DefaultOversizeDimensions() 
* DefaultJumboDimensions()  

"Standard" dimensions is the default.  To use any of the others, they can be passed to `WallPlate()`.

        WallPlate(DefaultOversizeDimensions()){
            Decora();
            Decora();
            Duplex();
        }

![](README.images/DecDecDupOver.png)

Most of the other modules in this library need to have `dimensions` defined either by passing it as a parameter, or more often because the global variable `$dimensions` is set to a dimensions vector.  It is through `$dimensions` that `WallPlate()` passes dimensions to the child modules drawing the devices.  The following expressions will produce the same output as above.

        $dimensions = DefaultOversizeDimensions();
        WallPlate(){
            Decora();
            Decora();
            Duplex();
        }

### Other examples

This repository includes the file `WallPlate_Examples.scad` which has several examples of using different modules.  Comment and un-comment out the sections or cut-n-paste them onto the OpenSCAD editor. 

## Libraries and their modules

See [Libraries and their modules](https://github.com/bpohl/WallPlate/wiki/Libraries-and-their-modules) on the wiki.










## <a id="Known Bugs"></a>Known Bugs

* Even

## Version

<!-- $Id$ -->

$Revision$<br>$Tags$

## Copyright

&copy; 2020 Bion Pohl/Omega Pudding Software Some Rights Reserved

$Author$<br>$Email$
