/**********************************************************************\
*
*  Assignment of values defining the size and shape of standard wall
*  plates and associated items.
*
\**********************************************************************/

/**************************************\
*  Various Default Values
\**************************************/
smooth = 360;    // Facet number ($fn).  We want smooth curves so I'm
                 // making it bigger than suggested
overlap = 0.125; // A little fudge factor that helps subtracted shapes
                 // cover the base shape

/* Center-to-Center of 1 Gang Standard */
dStandardGang  = mm(1+13/16);

/* Shared Plate Shape Parameters */
dThickness1    = mm(0.1);  // Overall thickness of the plate.
dThickness2    = mm(0.12); // Thickness at reinforcement around holes.
dRounding      = 0.8;      // Adjustment to radius of edge rounding.
                           // Value of 1 is 45 degree of circular
dRoundingSkew  = 1.1;      // Shift edge rounding from center of circle
                           // leaving flat edges.  Value of 1 is
                           // balanced continuous curve from outer edge.
dDepth         = mm(5/32); // How far the plate sticks out from the wall.
dDeepDepth     = mm(5/16); // Double depth plate.


/* Standard Wall Plate Dimensions */
dStandardDimensions = [mm(4+1/2),                     // height
                       (mm(2+3/4)-dStandardGang)/2,   // margin
                       dDepth,                        // depth
                       [dThickness1,dThickness2],     // [plate,reinforcement]
                                                      // thickness
                       dStandardGang,                 // gang width
                       [dRounding,dRoundingSkew]   ]; // [rounding,skew]
    
/* Midway Wall Plate Dimensions */
dMidwayDimensions   = [mm(5.06),                      // height
                       (mm(3.25)-dStandardGang)/2,    // margin
                       dDepth,                        // depth
                       [dThickness1,dThickness2],     // [plate,reinforcement]
                                                      // thickness
                       dStandardGang,                 // gang width
                       [dRounding,dRoundingSkew]   ]; // [rounding,skew]

/* Oversize Wall Plate Dimensions */
dOversizeDimensions = [mm(5+1/2),                     // height
                       (mm(3.36)-dStandardGang)/2,    // margin
                       dDepth,                        // depth
                       [dThickness1,dThickness2],     // [plate,reinforcement]
                                                      // thickness
                       dStandardGang,                 // gang width
                       [dRounding,dRoundingSkew]   ]; // [rounding,skew]

/* Jumbo Oversize Wall Plate Dimensions */
dJumboDimensions    = [mm(6.38),                      // height
                       (mm(4.5)-dStandardGang)/2,     // margin
                       dDepth,                        // depth
                       [dThickness1,dThickness2],     // [plate,reinforcement]
                                                      // thickness
                       dStandardGang,                 // gang width
                       [dRounding,dRoundingSkew]   ]; // [rounding,skew]

/* Screw Hole Sizes */
/* Size 6-32 which is standard for wall plates and devices */
dScrewHole6_32  = [mm(5/32),    // Screw hole (shaft) diameter
                   mm(17/64),   // Countersink (head) diameter
                   90,          // Screw Head Angle (degrees)
                   0.75      ]; // Screw Trap thickness


/**************************************\
*  Functions
\**************************************/

/* Getters for the Default Values for reference outside the library */
function DefaultSmooth()  = smooth;
function DefaultOverlap() = overlap;

function DefaultStandardGang() = dStandardGang;
function DefaultThickness()    = dThickness1;
function DefaultRounding()     = dRounding;
function DefaultRoundingSkew() = dRoundingSkew;
function DefaultDepth()        = dDepth;
function DefaultDeepDepth()    = dDeepDepth;

function DefaultStandardDimensions() = dStandardDimensions;
function DefaultMidwayDimensions()   = dMidwayDimensions;
function DefaultOversizeDimensions() = dOversizeDimensions;
function DefaultJumboDimensions()    = dJumboDimensions;

function DefaultScrewHole6_32()      = dScrewHole6_32;

/* Return the Standard Dimensions if global $dimensions is not set. */
function CurrentDimensions() = ifundef($dimensions,dStandardDimensions);

/* Getters for Dimension Vector */
function DimHeight(dimensions)       = dimensions[0];
function DimMargin(dimensions)       = dimensions[1];
function DimDepth(dimensions)        = dimensions[2];
function DimThickness(dimensions)    = dimensions[3][0];
function DimThickness1(dimensions)   = dimensions[3][0];
function DimThickness2(dimensions)   = dimensions[3][1];
function DimGangWidth(dimensions)    = dimensions[4];
function DimRounding(dimensions)     = dimensions[5][0];
function DimRoundingSkew(dimensions) = dimensions[5][1];

/* Plate Dimensions Vector Creator
   Set the values by name, values default to Current */
function DimensionsVector( height, margin, depth,
                           thickness, gangwidth, bevel,
                           platethickness, reinforcement,
                           rounding, skew,
                           dimensions = CurrentDimensions() ) =
    [ ifundef( height,    DimHeight(dimensions) ),     // height
      ifundef( margin,    DimMargin(dimensions) ),     // margin
      ifundef( depth,     DimDepth(dimensions) ),      // depth
      ifundef( thickness,                              // [plate,reinforcement]
               [ ifundef(platethickness,DimThickness1(dimensions)),
                 ifundef(reinforcement,DimThickness2(dimensions))   ] ),
      ifundef( gangwidth, DimGangWidth(dimensions) ),  // gang width
      ifundef( bevel,                                  // [rounding,skew]
               [ ifundef(rounding,DimRounding(dimensions)),
                 ifundef(skew,DimRoundingSkew(dimensions))  ] )          ];
