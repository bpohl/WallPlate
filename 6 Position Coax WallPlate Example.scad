/**********************************************************************\
*
*  6 Position Coaxial F-type Connector Example
*
*  This is an example of using the individual parts of a device
*  description to create a plate in a custom configuration.
*
\**********************************************************************/

/* Use just the libraries needed */
use <WallPlate/WallPlate_Generator.scad>;
use <WallPlate/WallPlate_Blank.scad>;
use <WallPlate/WallPlate_Coax.scad>;

/**********************************************************************\
*  
\**********************************************************************/
difference(){

    /* First union() all the positive (add) parts of the object need
       to be drawn as one and the first child to the difference()
       combination.                                                  */
    union(){

        /* Draw a 1 gang plate with no other features. */
        BlankPlate(1, center = true);

        /* Make a 2x3 array of cylinders that will be the reinforcements
           of the holes for the double-ended pass-through connectors.   */
        ToTop() color("blue")  // Move everything to be flush with the
                               //   surface of the plate. Make it blue.
            Distribute(mm(1.2), repeat = 2,  // Copy the columns of 3 twice.
                       vertical = false    ) 
                Distribute(mm(1.5), repeat = 3) // Make a vertical column of 3
                    // Use the size definitions from the Coax device 
                    cylinder( d = DevHexOpening(DefaultCoaxDimensions())+
                                    DimThickness2(DefaultStandardDimensions()),
                              h = DimThickness2(DefaultStandardDimensions()),
                              center = true, $fn = DefaultSmooth()           );

        /* Draw Screw Hole reinforcements using the add mode of Blank */
        Blank(add = true);
    }

    /* Now do the openings using the shape in the Coax library. */
    ToTop()  // Move everything to be flush with the surface of the plate. 
        Distribute(mm(1.2), repeat = 2,  // Copy the columns of 3 twice.
                   vertical = false    )
            Distribute(mm(1.5), repeat = 3)  // Make a vertical column of 3
                CoaxShape();  // Borrow the hex hole shape from Coax.

    /* Hollow the Screw Holes using the subtract mode of Blank */
    Blank(subtract = true);
}
