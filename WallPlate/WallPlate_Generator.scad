/**********************************************************************\
*
*  Module library that when used with other module files which
*  describe the geometries to add and subtract for a wall box mounted
*  device.  It can also be used to generate a wall plate of any
*  arbitrary size.
*
\**********************************************************************/

include <WallPlate_Dimensions.scad>;

/**************************************\
*  Functions
\**************************************/

/* Inch to mm conversion */
function mm(inch) = inch * 25.4;  // 1in = 25.4mm

/* Amount to raise (lower) an object of known thickness to be flush
with plate of know depth */
function top(depth = dStandardDimensions[2],
             thickness = dThickness1        ) = (depth-thickness)/2;

/* Return a default if undef. (Oft repeated pattern.) */
function ifundef(value,default) = (value == undef) ? default : value;

/* Calc overall width of plate given gang count and plate type */
function platewidth( gang = 1, margin, gangwidth,
                     dimensions = CurrentDimensions() ) =
    (ifundef(gangwidth,DimGangWidth(dimensions))*gang) +
      (ifundef(margin,DimMargin(dimensions))*2);

/* Returns a string showing the Add/Subtract mode */
function mode( add = $add, subtract = $subtract ) =
    str(add?"Add":"", (add&&subtract)?"/":"",subtract?"Subtract":"");


/**************************************\
*  Modules
\**************************************/

/**********************************************************************\
*
*  Generate a Wall Plate with the Devices listed as children.
*
*    dimensions  (vect[6] float)   Vector describing the plate dimensions 
*                                  to use [height, margin, depth, etc.]
*
*  The 'dimensions' vector needs to be in the prescribed form but can
*  be defined and passed to the module which will pass it on to the
*  Device modules for their use.
*
*  Usage:  WallPlate(){
*              Decora();
*              Duplex();
*              Duplex();
*          }
*
\**********************************************************************/
module WallPlate( dimensions = CurrentDimensions() ){

    echo("WallPlate", Devices = $children);
   
    difference(){
        
        /* Generate the blank plate of the needed gang count with the
           positive (add) geometries of the Devices                   */
        union(){
            BlankPlate( $children,
                        dimensions = dimensions,
                        center     = "first",
                        add = true, subtract = false );

            for($device = [0:1:$children-1]){
                echo(GangShift = $device*DimGangWidth(dimensions));
                    
                $add = true;
                translate([($device*DimGangWidth(dimensions)),0,0])
                    children($device);
            }
        }

        /* Generate the geometries to be removed (subtract) from the plate */
        for($device = [0:1:$children-1]){
            echo(GangShift = $device*DimGangWidth(dimensions));
            
            $subtract = true;
            translate([$device*DimGangWidth(dimensions),0,0])
                children($device);
        }

        /* Finish by rounding the plate edges */
        BlankPlate( $children,
                    dimensions = dimensions,
                    center     = "first",
                    add = false, subtract = true );
    }
}

    
/**********************************************************************\
*
*  Generate a rounded, hollowed plate shape of arbitrary size
*
*    gang          (pos int)         Set horizontal size based on number
*                                      of gang boxes
*    width         (pos float)       Horizontal size of plate
*    height        (pos float)       Vertical size of plate
*    depth         (pos float)       Overall distance from front face to wall
*    thickness     (pos float)       Distance between the outer face and
*                                      inner hollow, 0 to not create a hollow
*    rounding      (pos float)       Factor controlling the radius of the
*                                      cylindrical arch based on depth
*    skew          (pos float)       Makes the cylinder more eccentric to
*                                      shape the rounding, 1 is a circular
*                                      cross section,
*    dimensions    (vect[x])         Vector describing the plate dimensions
*                                      to use, [height, margin, depth, etc.]
*    colors        (vect[2] color)   Two color values to help distinguish
*                                      surfaces in preview
*    add/subtract  (bool)            Add/Subtract mode flags for debugging.
*
*  Supplying width, height, depth, etc. overrides the values derived from
*  dimensions/gang
*
\**********************************************************************/
module BlankPlate( gang = 1,
                   width,     height,   depth,
                   thickness, rounding, skew,
                   dimensions = CurrentDimensions(),
                   colors     = ["blue","yellow",["green","red"]],
                   center     = false,
                   add        = true,
                   subtract   = true                              ){

    rwidth     = ifundef(width,    platewidth(gang, dimensions = dimensions));
    rheight    = ifundef(height,   DimHeight(dimensions));
    rdepth     = ifundef(depth,    DimDepth(dimensions));
    rthickness = ifundef(thickness,DimThickness1(dimensions));
    rrounding  = ifundef(rounding, DimRounding(dimensions));
    rskew      = ifundef(skew,     DimRoundingSkew(dimensions));

    roundingradius = rdepth/rrounding;

    echo("BlankPlate", mode(add,subtract));
    //echo(rwidth,rheight,rdepth,roundingradius,rthickness,rskew,colors);

    /* Make placement a translate vector according to center value */
    placement = (center == "first") ?
                    -1*[(width == undef) ? 
                            (DimGangWidth(dimensions)/2)
                                + DimMargin(dimensions) :
                            rwidth/2,
                        rheight/2, rdepth/2              ] :
                (center == true) ?
                    -1*[rwidth/2, rheight/2, rdepth/2] :
                //(center == false)
                    [0,0,0];
    //echo(placement = placement);


    /* If in add AND subtract mode the complete beveled plate is
       drawn, otherwise the hollowed cube (body) can be created and
       "populated" with the edge bevel made later as a positive form
       and subtracted in the calling module.                          */
    translate(placement)  //Translate into desired center.

        //union(){  // Swap for difference() for debug.
        difference(){

            /* Draw the main body */
            if(add == true)
                color(colors[0]) cube([rwidth, rheight, rdepth]);
            
            /* Hollow out the shape down to the thickness but only if
               the outer body was drawn.                              */
            if((add == true)&&(0<rthickness)&&(rthickness<rdepth))
                translate([rthickness,rthickness,-overlap])
                BlankPlate(width          = (rwidth-(rthickness*2)),
                           height         = (rheight-(rthickness*2)),
                           depth          = (rdepth-rthickness+overlap),
                           roundingradius = roundingradius *
                                              ((rdepth-rthickness)/rdepth),
                           thickness      = 0, // Don't hollow out the hollow
                           colors         = ifundef(colors[2],["green","red"]),
                           center         = false,
                           add = true, subtract = true                       );
            
            /* Call to make the bevel form.  If add is true, this will
               be subtracted from the body by the difference().  If
               add is false, this is the only child of difference()
               and is drawn in the positive.                           */
            if(subtract == true) color(colors[1])
                PlateRounder( rwidth,     height,   depth,
                              thickness, rounding, skew,
                              dimensions = dimensions     );

        }
}


/**********************************************************************\
*
*  Place an EdgeRounder on all four edges of a plate.
*
*    length          (pos float)  The length of the edge to round. Required
*    roundingradius  (pos float)  Radius of the cylindrical arch.
*    skew            (pos float)  Makes the cylinder more eccentric
*                                   to shape the rounding. 
*                                   1 is a circular cross section.
*    dimensions      (vect[x])    Vector describing the plate dimensions
*                                   to use, [height, margin, depth, etc.]
*
\**********************************************************************/
module PlateRounder( width,     height,   depth,
                     thickness, rounding, skew,
                     dimensions = CurrentDimensions() ){

    rwidth     = ifundef(width,    platewidth(dimensions = dimensions));
    rheight    = ifundef(height,   DimHeight(dimensions));
    rdepth     = ifundef(depth,    DimDepth(dimensions));
    rthickness = ifundef(thickness,DimThickness1(dimensions));
    rrounding  = ifundef(rounding, DimRounding(dimensions));
    rskew      = ifundef(skew,     DimRoundingSkew(dimensions));

    roundingradius = rdepth/rrounding;

    //echo(rwidth,rheight,rdepth,roundingradius,rthickness,rrounding,rskew);

    translate([rwidth/2, rheight/2, rdepth]){
        /* Draw the top and bottom */
        Distribute( spread     = rheight,
                    vertical   = true     ){
            rotate([0,0,180])
                EdgeRounder(rwidth,
                            roundingradius = roundingradius,
                            skew           = skew,
                            dimensions     = dimensions      );
            rotate([0,0,0])
                EdgeRounder(rwidth,
                            roundingradius = roundingradius,
                            skew           = skew,
                            dimensions     = dimensions      );
        }

        /* Draw the sides */
        Distribute( spread     = rwidth,
                    vertical   = false   ){
            rotate([0,0,270])
                EdgeRounder(rheight,
                            roundingradius = roundingradius,
                            skew           = skew,
                            dimensions     = dimensions      );
            rotate([0,0,90])
                EdgeRounder(rheight,
                            roundingradius = roundingradius,
                            skew           = skew,
                            dimensions     = dimensions      );
        }
    }
}


/**********************************************************************\
*
*  Generate a shape that can be subtracted from the plate body to
*  create a rounded edge bevel.
*
*    length          (pos float)  The length of the edge to round. Required
*    roundingradius  (pos float)  Radius of the cylindrical arch
*    skew            (pos float)  Makes the cylinder more eccentric
*                                   to shape the rounding, 
*                                   1 is a circular cross section,
*    dimensions      (vect[x])    Vector describing the plate dimensions
*                                   to use, [height, margin, depth, etc.]
*
\**********************************************************************/
module EdgeRounder( length, roundingradius, skew,
                    dimensions = CurrentDimensions() ){

    rlength         = ifundef(length,
                              platewidth( gang = 1,
                                          dimensions = CurrentDimensions() ));
    rskew           = ifundef(skew,DimRoundingSkew(dimensions));
    rroundingradius = ifundef(roundingradius,
                              DimDepth(dimensions)/DimRounding(dimensions));

    skew_y = (rskew<1) ? 1 : rskew;
    skew_z = (rskew>1) ? 1 : rskew;
    //echo(skew_y = skew_y, skew_z = skew_z, 
    //     rroundingradius = rroundingradius);

    //union(){  // Swap for difference() for debug.
    difference(){
        cube([rlength+(overlap*2),
              rroundingradius*2*skew_z,
              rroundingradius*2/skew_y],
             center = true              );

        scale([1,skew_y,1/skew_z])
            translate([0, rroundingradius/skew_y, -rroundingradius*skew_z])
            rotate([0, 90, 0])
            color("orange") cylinder(r      = rroundingradius,
                                     h      = rlength+(overlap*4),
                                     center = false,
                                     $fn    = smooth,
                                     center = true               );
    }
}


/**********************************************************************\
*
*  Re-round the top and bottom edge of the plate if something has
*  extended beyond it.
*
*  Preface the device for the gang needing the rounding.
*
*    ReRound() Decora();
*
\**********************************************************************/
module ReRound( dimensions = CurrentDimensions(),
                add        = $add,
                subtract   = $subtract            ){
    
    echo(ReRound = $device, mode(add,subtract));
    
    if(subtract == true)
        translate([0, 0, DimDepth(dimensions)/2])
            //render()  // Force the render because OpenCSG doesn't hide
                        // the whole object
                Distribute( spread   = DimHeight(dimensions),
                            vertical = true                   ){
                    rotate([0,0,180]) EdgeRounder(dimensions = dimensions);
                    rotate([0,0,  0]) EdgeRounder(dimensions = dimensions);
                }
    children();
}


/**********************************************************************\
*
*  Distribute a number of objects vertically or horizontally
*  
*  Passes the add/subtract flags to its children.
*
*    spread    (pos float)  Center distance between furthest objects.
*    repeat    (pos int)    If only 1 object, repeat it this number times.
*    placement (pos int)    Number 0-7 giving count and position
*                             of up to three openings, (Think binary
*                             coded octal) Defaults to 2.
*    vertical  (bool)       Defaults to true, false spreads objects
*                             horizontally.
*
\**********************************************************************/
module Distribute( spread   = 0,
                   repeat   = 1,
                   placement,
                   vertical = true ){

    kids       = ($children > 1) ? $children
                                 : (placement == undef) ? abs(repeat) : 3;
    rspread    = ((kids > 1) || (placement != undef)) ? spread : 0;
    rplacement = ifundef(placement,2);
    step       = rspread/(kids-1+pow(10,-81)); // Add a number so small it
                                               // won't matter but is not 0
    
    //echo("Distribute", children = $children, placement = rplacement,
    //     kids = kids, spread = rspread, step = step);

    /* For a given num, in binary is the bit at pwr set */
    function bit(num,pwr) = (ceil((num+1)/pow(2,pwr))%2 == 0);

    for($object = [0:1:kids-1]){
        kid = ($children > 1) ? $object : 0;

        //echo("-- ",object = $object, kid = kid,
        //     pos = (rspread/2)-($object*step));

        if((($object == 0) && bit(rplacement,0)) ||
           (($object == 1) && bit(rplacement,1)) ||
           (($object == 2) && bit(rplacement,2)) ||
           (placement == undef) || ($children > 1)  ){

        translate((vertical == true) ? [0, (rspread/2)-($object*step), 0] :
                                       [($object*step)-(rspread/2), 0, 0]  )
            children(kid);
        }}
}


/********************************************************************** \
*
*  Translate all children from the center to the surface of the plate.
*  
*    thickness   (pos float)  The thickness of the object.
*    depth       (pos float)  The depth of the plate.
*    dimensions  (vect[x])    Vector describing the plate dimensions
*                               to use, [height, margin, depth, etc.]
*                               horizontally.
*
\**********************************************************************/
module ToTop( thickness, depth,
              dimensions = CurrentDimensions() ){

    rthickness = ifundef(thickness,DimThickness2(dimensions));
    rdepth     = ifundef(depth,    DimDepth(dimensions));

    echo("ToTop", depth = rdepth, thickness = rthickness);
    
    translate([0, 0, top(rdepth, rthickness)]) children();
}


/**********************************************************************\
*
*  Countersinked Screw Holes with Reinforcing
*  
*  Employs the same add/subtract method as the device modules.
*
*    depth           (pos float)  Force length of screw hole and its
*                                   reinforcing, otherwise taken from
*                                   dimensions vector.
*    scalar          (pos float)  Amount to expand screw shape to make
*                                   a reinforcement.  Defaults to ratio of
*                                   screw diameter to plate thickness.
*    screwtrap       (pos float)  Thickness of the screwtrap, overrides
*                                   value in screw vector.
*    dimensions      (vect[x])    Vector describing the plate dimensions
*                                   to use, [height, margin, depth, etc.]
*    screw           (vect[4])    Vector describing the screw dimensions,
*                                   defaults to dScrewHole6_32.
*    add/subtract    (bool)       Add/Subtract mode flags for debugging.
*
\**********************************************************************/
module CSScrewHole( depth,
                    scaler,
                    screwtrap,
                    dimensions = CurrentDimensions(),
                    screw      = dScrewHole6_32,
                    add        = $add,
                    subtract   = $subtract            ){

    rdepth     = ifundef(depth,    DimDepth(dimensions));
    rscrewtrap = ifundef(screwtrap,screw[3]);
    rscaler    = ifundef(scaler,   screw[0]/DimThickness1(dimensions));

    echo("ScrewHole", mode(add,subtract));

    /* Cross section triangle of the Countersink */
    csink_xsection = [[0,                             0],
                      [((screw[1]-screw[0]))+overlap, 0],
                      [0,-(((screw[1]-screw[0])+overlap) / tan(screw[2]/2))]];
    //echo(csink_xsection = csink_xsection);

    module ScrewShape(shaft){

        /* The main channel */
        cylinder(r = (screw[0]/2)+(overlap*2),
                 h = shaft,
                 center = true, $fn = smooth  );

        /* Put on the countersink head but isolate it
           to the length of the shaft                 */
        //union(){
        render() intersection(){
            rotate_extrude($fn = smooth)
                translate([screw[0]/2-overlap, shaft/2, 0])
                    polygon(csink_xsection);

            cylinder(r = screw[1], h = shaft,
                     center = true, $fn = smooth  );
        }
    }
    
    if(add == true){
        //echo(scalar = scalar);
        color("blue") scale([rscaler,rscaler,1]) ScrewShape(rdepth);
    }

    if(subtract == true){
        color("yellow")
            difference(){        
                ScrewShape(rdepth+(overlap/2));

                /* Add a reduced channel to hold the screw
                   just below the countersink              */
                if(rscrewtrap > 0)
                    translate([0, 0, (rdepth/2)+csink_xsection[2][1]+overlap])
                        difference(){
                            cylinder(r = (screw[0]/2+(overlap*2)),
                                     h = rscrewtrap,
                                     center = true, $fn = smooth);
                            cylinder(r = (screw[0]/2+(overlap*4)),
                                     h = rscrewtrap+overlap,
                                     center = true, $fn = 3     );
                    }
        }
    }
}

