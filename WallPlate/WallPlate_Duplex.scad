/************************************************************\
*
*  Duplex Outlet Plate
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

/* Duplex Device Dimensions */
dDuplexDimensions = [mm(1+1/8),     // The opening height
                     mm(1+11/32),   // The opening width
                     mm(1+1/2)   ]; // Opening spacing


//===============================
//  Functions
//===============================
/* Getters for the Default Values for reference outside the library */
function DefaultDuplexDimensions() = dDuplexDimensions;

/* Getters for Device Dimension Vector */
function DevHeight(devicedimensions)  = devicedimensions[0];
function DevWidth(devicedimensions)   = devicedimensions[1];
function DevSpacing(devicedimensions) = devicedimensions[2];


/**********************************************************************\
*
*  Duplex devices fit a circle with two flattened sides.
*  
*    thickness        (pos float)  Top to bottom size of object.
*    devicedimensions (vect[x])    Vector describing the dimensions of
*                                    the device openings.
*    dimensions       (vect[x])    Vector describing the plate dimensions
*                                    to use, [height, margin, depth, etc.]
*
\**********************************************************************/
module DuplexShape(thickness,
                   devicedimensions = dDuplexDimensions,
                   dimensions       = CurrentDimensions()){

    rthickness = ifundef(thickness, DimThickness2(dimensions));

    render() // Force the render because OpenCSG doesn't
             // hide the whole object
        intersection(){
            cylinder( r = DevWidth(devicedimensions)/2,
                      h = rthickness,
                      center=true, $fn=smooth           );

            cube([DevWidth(devicedimensions),
                  DevHeight(devicedimensions),
                  rthickness                   ],
                 center = true                    );
    }
}
    

/**********************************************************************\
*
*  Duplex Device Plate
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
module Duplex( devicedimensions = dDuplexDimensions,
               dimensions       = CurrentDimensions(),
               add              = $add,
               subtract         = $subtract                   ){
    
    $add      = add;
    $subtract = subtract ;

    echo(Duplex = $device, mode(add,subtract));

    /* Make a shape that is a bit bigger to be reinforcement. */
    if(add == true){
        scaler = DimThickness2(dimensions)/DimThickness1(dimensions);
        //echo(scaler = scaler);
        
        color("blue")
            ToTop(dimensions = dimensions)
                Distribute(DevSpacing(devicedimensions), repeat = 2)
                    scale([scaler,scaler,1])
                        DuplexShape( DimThickness2(dimensions),
                                     devicedimensions = devicedimensions,
                                     dimensions       = dimensions        );
    }
    
    /* Now make the right size openings. */
    if(subtract == true)
        color("yellow")
            ToTop(dimensions = dimensions)
                Distribute(DevSpacing(devicedimensions), repeat = 2)
                    DuplexShape( DimThickness2(dimensions)+(overlap*2),
                                 devicedimensions = devicedimensions,
                                 dimensions       = dimensions          );
    
    /* Screw Holes */
    ToTop(dimensions = dimensions) CSScrewHole(DimThickness2(dimensions));
}

