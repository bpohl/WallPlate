/**********************************************************************\
*
*  Some Examples.
*
*  Uncomment sections one at a time to see what they draw.  If you do
*  more than one they will bunch up.
*
*  Tip: Change /** to //**
*
\**********************************************************************/

/* Just include all the Devices */
include <WallPlate/WallPlate_IncludeAll.scad>;

/**********************************************************************\
*  Zen Plate, "One with everything".
*  Uncomment the various dimension sizes to see the difference. 
\**********************************************************************/
//**
//$dimensions = DefaultOversizeDimensions();
//$dimensions = DefaultJumboDimensions();
//$dimensions = DimensionsVector( depth = 12, rounding = 4, skew = 1 );
WallPlate(){
    Coax(5);
    Decora();
    Despard(5);
    Duplex();
    PushbuttonSwitch();
    ToggleSwitch();    
}


/**********************************************************************\
*  Make a 2 gang plate with no cut-outs centered on the first gang.
\**********************************************************************/
/**
BlankPlate(gang = 2, center = "first");


/**********************************************************************\
*  Show what you get when the Device definitions are run by themselves.
*  The blue is what will be added (the reinforcements) and the yellow
*  is what will be taken away (the cut-out).
\**********************************************************************/
/**
Distribute(DefaultStandardGang()*8, vertical = false){
    CSScrewHole(mm(1), add=true, subtract = true);
    Blank(add = true, subtract = true);
    Coax(5,add = true, subtract = true);
    Decora(add = true, subtract = true);
    Despard(add = true, subtract = true, devices = 2, vertical = false );
    Duplex(add = true, subtract = true);
    PushbuttonSwitch(add = true, subtract = true);
    ToggleSwitch(add = true, subtract = true);
}


/**********************************************************************\
*  Some Devices with complex shapes have it drawn in a
*  separate module so it can be used by itself. 
\**********************************************************************/
/**
Distribute(DefaultStandardGang()*5, vertical = false){
    CoaxShape();
    DecoraShape();
    DespardShape();
    DuplexShape();
    PushbuttonShape();
}


/**********************************************************************\
*  Show what Distribute does with Lists, Repeat, and Placement.
\**********************************************************************/
/**
Distribute(DimHeight(DefaultStandardDimensions())){
    Distribute(DefaultStandardGang()*2, vertical = false){
        // List of objects
        Distribute(spread = mm(2)){
            CoaxShape();
            DespardShape();
            PushbuttonShape();
        }

        // Repeat one object
        Distribute(spread = mm(2), repeat = 4) CoaxShape();
    }
    Distribute(DefaultStandardGang()*8, vertical = false){
        // Placement defined by octal
        Distribute(spread = mm(2), placement = 0) CoaxShape();
        Distribute(spread = mm(2), placement = 1) CoaxShape();
        Distribute(spread = mm(2), placement = 2) CoaxShape();
        Distribute(spread = mm(2), placement = 3) CoaxShape();
        Distribute(spread = mm(2), placement = 4) CoaxShape();
        Distribute(spread = mm(2), placement = 5) CoaxShape();
        Distribute(spread = mm(2), placement = 6) CoaxShape();
        Distribute(spread = mm(2), placement = 7) CoaxShape();
    }
}

**/
