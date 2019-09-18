/************************************************************\
*
*  Despard Wall Plate
*
\************************************************************/

use <WallPlate_Generator.scad>;

//===============================
//  Various Default Values
//===============================
smooth  = DefaultSmooth();  // Facet number ($fn).  We want smooth curves 
                            // so. I'm making it bigger than suggested
overlap = DefaultOverlap(); // A little fudge factor that helps subtracted
                            // shapes cover the base shape.

/* Duplex Device Dimensions */
dDespardDimensions = [mm(0.674),    // The opening height
                      mm(0.916),    // The opening width
                      mm(59/64)*2,  // Horizontal device spacing
                      mm(2),        // Vertical device spacing
                      mm(3+13/16)]; // The separation between screw holes


//===============================
//  Functions
//===============================
/* Getters for the Default Values for reference outside the library */
function DefaultDespardDimensions() = dDespardDimensions;

/* Getters for Device Dimension Vector */
function DevHeight(devicedimensions)   = devicedimensions[0];
function DevWidth(devicedimensions)    = devicedimensions[1];
function DevHSpacing(devicedimensions) = devicedimensions[2];
function DevVSpacing(devicedimensions) = devicedimensions[3];
function DevScrewSep(devicedimensions) = devicedimensions[4];


/**********************************************************************\
*
*  Despard devices fit a circle with two flattened sides.
*  
*    thickness        (pos float)  Top to bottom size of object.
*    vertical         (bool)       Rotate openings 90 degrees.
*    dimensions       (vect[x])    Vector describing the plate dimensions
*                                    to use, [height, margin, depth, etc.]
*    devicedimensions (vect[x])    Vector describing the dimensions of
*                                    the device openings.
*
\**********************************************************************/
module DespardShape(thickness,
                    vertical         = false,
                    devicedimensions = dDespardDimensions,
                    dimensions       = CurrentDimensions() ){

    rthickness = ifundef(thickness, DimThickness2(dimensions));
    
    render() // Force the render because OpenCSG doesn't hide
             // the whole object
        rotate([0,0,(vertical?90:0)])
            intersection(){
                cylinder( r = DevWidth(devicedimensions)/2,
                          h = rthickness,
                          center=true, $fn=smooth           );

                cube( [DevWidth(devicedimensions),
                       DevHeight(devicedimensions),
                       rthickness                   ],
                      center = true                   );
            }
}


/**********************************************************************\
*
*  Despard Wall Plate
*  
*  Employs the same add/subtract method as the device modules.
*
*    devices          (pos int)    Number 0-7 giving count and position
*                                  of up to three openings, (Think binary
*                                  coded octal) Defaults to 2.
*    vertical         (bool)       Set to true to turn the opening by
*                                  90 degrees.
*    scalar           (pos float)  Amount to expand opening shape to make
*                                  a reinforcement.  Defaults to ratio of
*                                  reinforcement to plate thickness.
*    devicedimensions (vect[x])    Vector describing the dimensions of
*                                  the device openings.
*    dimensions       (vect[x])    Vector describing the plate dimensions
*                                  to use, [height, margin, depth, etc.]
*    screwtrap        (pos float)  Thickness of the screwtrap, overrides
*                                  value in screw vector.
*    add/subtract     (bool)       Add/Subtract mode flags for debugging.
*
\**********************************************************************/
module Despard( devices          = 2,
                vertical,
                scalar,
                devicedimensions = dDespardDimensions,
                dimensions       = CurrentDimensions(),
                add              = $add,
                subtract         = $subtract                   ){
    
    echo(Despard = $device, mode(add,subtract));

    $add      = add;
    $subtract = subtract ;

    rscalar   = ifundef(scalar,
                        DimThickness2(dimensions)/DimThickness1(dimensions));

    spacing   = (vertical ? DevVSpacing(devicedimensions)
                          : DevHSpacing(devicedimensions));


    /* Make a shape that is a bit bigger to be reinforcement. */
    if(add == true) color("blue")
        ToTop(dimensions = dimensions)
            Distribute( spacing,
                        placement = devices,
                        vertical = true      )
                scale([rscalar,rscalar,1])
                        DespardShape(thickness = DimThickness2(dimensions),
                                     vertical  = vertical,
                                     devicedimensions = devicedimensions,
                                     dimensions       = dimensions          );

    /* Now make the right size openings. */
    if(subtract == true) color("yellow")
        ToTop(dimensions = dimensions)
            Distribute( spacing,
                        placement = devices,
                        vertical = true      )
                DespardShape(thickness = DimThickness2(dimensions)+(overlap*2),
                             vertical  = vertical,
                             devicedimensions = devicedimensions,
                             dimensions       = dimensions                   );

    /* Screw Holes */
    ToTop(dimensions = dimensions)
        Distribute(DevScrewSep(devicedimensions), repeat = 2)
            CSScrewHole(DimThickness2(dimensions));
}

