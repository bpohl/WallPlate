/************************************************************\
*
*  Toggle Switch Plate
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
dToggleSwitchDimensions = [mm(0.942),	// The height of a light switch
                           mm(0.406),	// The width of a light switch
                           mm(2+3/8) ]; // The separation between screw holes


//===============================
//  Functions
//===============================
/* Getters for the Default Values for reference outside the library */
function DefaultToggleSwitchDimensions() = dToggleSwitchDimensions;

/* Getters for Device Dimension Vector */
function DevHeight(devicedimensions)   = devicedimensions[0];
function DevWidth(devicedimensions)    = devicedimensions[1];
function DevScrewSep(devicedimensions) = devicedimensions[2];


/**********************************************************************\
*
*  Toggle Switch Plate
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
module ToggleSwitch( devicedimensions = dToggleSwitchDimensions,
                     dimensions       = CurrentDimensions() ,
                     add              = is_undef($add)?undef:$add,
                     subtract         = is_undef($subtract)?undef:$subtract ){

    echo(Switch = $device, add?"Add":"", subtract?"Subtract":"");

    $add      = add;
    $subtract = subtract ;

    /* Make a shape that is a bit bigger to be reinforcement. */
    if(add == true)
        color("blue")
            ToTop(dimensions = dimensions)
                cube(size = [DevWidth(devicedimensions)
                               +DimThickness2(dimensions),
                             DevHeight(devicedimensions)
                               +DimThickness2(dimensions),
                             DimThickness2(dimensions)    ],
                     center = true                          );

    /* Now make the right size openings. */
    if(subtract == true)
        color("yellow")
            ToTop(dimensions = dimensions)
                cube(size = [DevWidth(devicedimensions),
                             DevHeight(devicedimensions),
                             DimThickness2(dimensions)+(overlap*2)],
                     center = true                                  );

    /* Screw Holes */
    ToTop(dimensions = dimensions)
        Distribute(DevScrewSep(devicedimensions), repeat = 2)
            CSScrewHole(DimThickness2(dimensions));
}

