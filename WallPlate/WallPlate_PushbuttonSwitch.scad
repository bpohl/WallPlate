/************************************************************\
*
*  "Old Fashioned" Pushbutton Switch Plate
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

/* Lever Pushbutton Switch Dimensions */
dPushbuttonSwitchDimensions = [mm(9/16),	// Diameter of cutouts
                               mm(15/16),	// The center separation of cutouts
                               mm(2+3/8) ]; // The separation between screw
                                            // holes


//===============================
//  Functions
//===============================
/* Getters for the Default Values for reference outside the library */
function DefaultPushbuttonSwitchDimensions() = dPushbuttonSwitchDimensions;

/* Getters for Device Dimension Vector */
function DevDiameter(devicedimensions)  = devicedimensions[0];
function DevCutoutSep(devicedimensions) = devicedimensions[1];
function DevScrewSep(devicedimensions)  = devicedimensions[2];


/**********************************************************************\
*
*  Just a circular hole of the right size.
*  
*    thickness        (pos float)  Top to bottom size of object.
*    devicedimensions (vect[x])    Vector describing the dimensions of
*                                    the device openings.
*    dimensions       (vect[x])    Vector describing the plate dimensions
*                                    to use, [height, margin, depth, etc.]
*
\**********************************************************************/
module PushbuttonShape(thickness,
                       devicedimensions = dPushbuttonSwitchDimensions,
                       dimensions       = CurrentDimensions()          ){

    rthickness = ifundef(thickness, DimThickness2(dimensions));
    
    cylinder(d = DevDiameter(devicedimensions),
             h = rthickness,
             center = true, $fn=smooth           );
}


/**********************************************************************\
*
*  Pushbutton Switch
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
module PushbuttonSwitch( devicedimensions = dPushbuttonSwitchDimensions,
                         dimensions       = CurrentDimensions(),
                         add              = is_undef($add)?undef:$add,
                         subtract         = is_undef($subtract)?undef
                                                               :$subtract ){

    echo(Pushbutton = $device, add?"Add":"", subtract?"Subtract":"");

    $add      = add;
    $subtract = subtract ;

    /* Make a shape that is a bit bigger to be reinforcement. */
    if(add == true){
        scaler=DimThickness2(dimensions)/DimThickness1(dimensions);
        echo(scaler = scaler);
        
        color("blue")
            ToTop(dimensions = dimensions)
                Distribute(DevCutoutSep(devicedimensions), repeat = 2)
                    scale([scaler,scaler,1])
                        PushbuttonShape(DimThickness2(dimensions),
                                        devicedimensions = devicedimensions,
                                        dimensions       = dimensions        );
    }

    /* Now make the right size openings. */
    if(subtract == true)
        color("yellow")
            ToTop(dimensions = dimensions)
                Distribute(DevCutoutSep(devicedimensions), repeat = 2)
                    PushbuttonShape(DimThickness2(dimensions)+(overlap*2),
                                    devicedimensions = devicedimensions,
                                    dimensions       = dimensions          );

    /* Screw Holes */
    ToTop(dimensions = dimensions)
        Distribute(DevScrewSep(devicedimensions), repeat = 2)
            CSScrewHole(DimThickness2(dimensions));
}

