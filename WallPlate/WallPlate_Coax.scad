/************************************************************\
*
*  Coax plate with screw holes 
*
\************************************************************/

use <WallPlate_Generator.scad>;

/**************************************\
*  Various Default Values
\**************************************/
smooth  = DefaultSmooth();  // Facet number ($fn).  We want smooth curves 
                            // so. I'm making it bigger than suggested
overlap = DefaultOverlap(); // A little fudge factor that helps subtracted
                            // shapes cover the base shape.

/* Coax Joiner Pass-through Dimensions */
dCoaxDimensions = [12.5,         // Hex diameter (point to point)
                   9.4,          // Opening diameter
                   mm(1.5),      // Vertical device spacing
                   mm(3+9/32) ]; // The separation between screw holes


/**************************************\
*  Functions
\**************************************/
/* Getters for the Default Values for reference outside the library */
function DefaultCoaxDimensions() = dCoaxDimensions;

/* Getters for Device Dimension Vector */
function DevHexOpening(devicedimensions) = devicedimensions[0];
function DevOpening(devicedimensions)    = devicedimensions[1];
function DevSpacing(devicedimensions)    = devicedimensions[2];
function DevScrewSep(devicedimensions)   = devicedimensions[3];


/********************************************************************** \
*
*  A cylindrical hole shape for Coaxial F-type pass-through connector.
*  The top half of the cylinder is hexagonal to receive that part of
*  the connector.
*  
*    thickness        (pos float)  Top to bottom size of object.
*    dimensions       (vect[x])    Vector describing the plate dimensions
*                                    to use, [height, margin, depth, etc.]
*    devicedimensions (vect[x])    Vector describing the dimensions of
*                                    the device openings.
*
\**********************************************************************/
module CoaxShape( thickness,
                  hexdiameter,
                  openingdiameter,
                  devicedimensions = dCoaxDimensions,
                  dimensions       = CurrentDimensions() ){
    
    rthickness   = ifundef(thickness,       DimThickness2(dimensions));
    rhexdiameter = ifundef(hexdiameter,     DevHexOpening(devicedimensions));
    ropeningdiam = ifundef(openingdiameter, DevOpening(devicedimensions));

    //echo(thickness       = rthickness,
    //     hexdiameter     = rhexdiameter,
    //     openingdiameter = ropeningdiam);
    
    /* A cylinder with 6 facets ($fn = 6) is a hexagon. */
    cylinder( d = rhexdiameter,
              h = (rthickness/2)+overlap,
              center = false, $fn = 6     );

    cylinder( d = ropeningdiam,
              h = rthickness+(overlap*2),
              center = true, $fn = smooth );
}


/********************************************************************** \
*
*  Coax Wall Plate
*  
*  Employs the same add/subtract method as the device modules.
*
*    devices          (pos int)    Number 0-7 giving count and position
*                                    of up to three openings, (Think binary
*                                    coded octal) Defaults to 2.
*    scalar           (pos float)  Amount to expand opening shape to make
*                                    a reinforcement.  Defaults to ratio of
*                                    reinforcement to plate thickness.
*    devicedimensions (vect[x])    Vector describing the dimensions of
*                                    the device openings.
*    dimensions       (vect[x])    Vector describing the plate dimensions
*                                    to use, [height, margin, depth, etc.]
*    add/subtract     (bool)       Add/Subtract mode flags for debugging.
*
\**********************************************************************/
module Coax( devices          = 2,
             scalar,
             devicedimensions = dCoaxDimensions,
             dimensions       = CurrentDimensions(),
             add              = is_undef($add)?undef:$add,
             subtract         = is_undef($subtract)?undef:$subtract ){
    
    echo(Coax = $device, mode(add,subtract));

    $add      = add;
    $subtract = subtract;

    rscalar = ifundef(scalar,
                      DimThickness2(dimensions)/DimThickness1(dimensions));

    /* Objects to add to the plate. */
    if(add == true) color("blue")
        ToTop(dimensions = dimensions)
            Distribute( DevSpacing(devicedimensions),
                        placement = devices,
                        vertical = true               )
            cylinder( d = DevHexOpening(devicedimensions)*rscalar,
                      h = DimThickness2(dimensions),
                      center = true, $fn = smooth                  );


    /* Holes to open in the plate and added objects. */
    if(subtract == true) color("yellow")
        ToTop(dimensions = dimensions)
            Distribute( DevSpacing(devicedimensions),
                        placement = devices,
                        vertical = true               )
                CoaxShape( devicedimensions = devicedimensions,
                           dimensions       = dimensions        );

    /* Screw Holes */
    Distribute(DevScrewSep(devicedimensions), repeat = 2)
        CSScrewHole(DimDepth(dimensions));
}

