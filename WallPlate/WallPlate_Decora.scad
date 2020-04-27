/************************************************************\
*
*  Decora Wall Plate
*
\************************************************************/

use <WallPlate_Generator.scad>;

//===============================
//  Various Default Values
//===============================
smooth  = DefaultSmooth();  // Facet number ($fn).  We want smooth curves so
                            // I'm making it bigger than suggested
overlap = DefaultOverlap(); // A little fudge factor that helps subtracted
                            // shapes cover the base shape

/* Lever Toggle Switch Dimensions */
dDecoraDimensions = [66.8,   // The height of a light switch
                     33.2,   // The width of a light switch
                     2.54,   // Corner rounding radius
                     96.8 ]; // The separation between screw holes


//===============================
//  Functions
//===============================
/* Getters for the Default Values for reference outside the library */
function DefaultDecoraDimensions() = dDecoraDimensions;

/* Getters for Device Dimension Vector */
function DevHeight(devicedimensions)   = devicedimensions[0];
function DevWidth(devicedimensions)    = devicedimensions[1];
function DevRounding(devicedimensions) = devicedimensions[2];
function DevScrewSep(devicedimensions) = devicedimensions[3];


/**********************************************************************\
*
*  Decora devices fit a rectangular opening with rounded corners.
*  
*    height           (pos float)  Height of the rectangle.
*    width            (pos float)  Width of the rectangle.
*    thickness        (pos float)  Top to bottom size of object.
*    rounding         (pos float)  Radius of the corner rounding.
*    dimensions       (vect[x])    Vector describing the plate dimensions
*                                    to use, [height, margin, depth, etc.]
*    devicedimensions (vect[x])    Vector describing the dimensions of
*                                    the device openings.
*
\**********************************************************************/
module DecoraShape( height, width, thickness, rounding,
                    devicedimensions = dDecoraDimensions,
                    dimensions       = CurrentDimensions() ){

    rheight    = ifundef(height,    DevHeight(devicedimensions));
    rwidth     = ifundef(width,     DevWidth(devicedimensions));
    rthickness = ifundef(thickness, DimThickness2(dimensions));
    rrounding  = ifundef(rounding,  DevRounding(devicedimensions));

    //echo(height = rheight, width = rwidth,
    //     thickness = rthickness, rounding = rrounding);
    
    minkowski(){
        cube( size   = [ rwidth - (rrounding*2),
                         rheight - (rrounding*2),
                         rthickness/2             ],
              center = true                          );
        cylinder( r = rrounding,
                  h = rthickness/2,
                  center = true,  $fn=smooth );
    }
}


/**********************************************************************\
*
*  Decora Wall Plate
*  
*  Employs the same add/subtract method as the device modules.
*
*    devicedimensions (vect[x])  Vector describing the dimensions of
*                                the device openings.
*    dimensions       (vect[x])  Vector describing the plate dimensions
*                                to use, [height, margin, depth, etc.]
*    add/subtract     (bool)     Add/Subtract mode flags for debugging.
*
\**********************************************************************/
module Decora( devicedimensions = dDecoraDimensions,
               dimensions       = CurrentDimensions(),
               add              = is_undef($add)?undef:$add,
               subtract         = is_undef($subtract)?undef:$subtract ){

    echo(Decora = $device, mode(add,subtract));

    $add      = add;
    $subtract = subtract ;

    /* Make a shape that is a bit bigger to be reinforcement. */
    if(add == true) color("blue")
        ToTop(dimensions = dimensions)
            DecoraShape (height    = DevHeight(devicedimensions)
                                       +(DimThickness2(dimensions)*2),
                         width     = DevWidth(devicedimensions)
                                       +(DimThickness2(dimensions)*2),
                         thickness = DimThickness2(dimensions),
                         devicedimensions = devicedimensions,
                         dimensions       = dimensions                 );

    /* Now make the right size opening. */
    if(subtract == true) color("yellow")
        ToTop(dimensions = dimensions)
            DecoraShape( height    = DevHeight(devicedimensions),
                         width     = DevWidth(devicedimensions),
                         thickness = DimThickness2(dimensions)+(overlap*2),
                         devicedimensions = devicedimensions,
                         dimensions       = dimensions                      );

    /* Screw Holes */
    ToTop(dimensions = dimensions)
        Distribute(DevScrewSep(devicedimensions), repeat = 2)
            CSScrewHole(DimThickness2(dimensions));
}
