/************************************************************\
*
*  Blank plate with screw holes 
*
\************************************************************/

use <WallPlate_Generator.scad>;

/**************************************\
*  Various Default Values
\**************************************/
/* Lever Toggle Switch Dimensions */
dBlankDimensions = [mm(3+9/32) ]; // The separation between screw holes


/**************************************\
*  Functions
\**************************************/
/* Getters for the Default Values for reference outside the library */
function DefaultBlankDimensions() = dBlankDimensions;

/* Getters for Device Dimension Vector */
function DevScrewSep(devicedimensions) = devicedimensions[0];


/**********************************************************************\
*
*  Blank Wall Plate
*  
*  Employs the same add/subtract method as the device modules.
*
*    devicedimensions (vect[x])    Vector describing the dimensions of
*                                  the device openings.
*    dimensions       (vect[x])    Vector describing the plate dimensions
*                                  to use, [height, margin, depth, etc.]
*    add/subtract     (bool)       Add/Subtract mode flags for debugging.
*
\**********************************************************************/
module Blank( devicedimensions = dBlankDimensions,
              dimensions       = CurrentDimensions(),
              add              = $add,
              subtract         = $subtract            ){
    
    echo(Blank = $device, mode(add,subtract));

    $add      = add;
    $subtract = subtract;

    /* Screw Holes */
    Distribute(DevScrewSep(devicedimensions), repeat = 2)
        CSScrewHole(DimDepth(dimensions));
}

