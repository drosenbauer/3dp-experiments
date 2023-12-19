// minute hand hole ID = 5.2mm
// hour hand hole ID = 3.3mm

/* [Model to export:] */
// Which part of the model to export
PART="all"; // [face, minute, hour, frame, all]

/* [Dimensions of your movement:] */
// The diameter of the minute hand hole in mm
MINUTE_HAND = 3.6;

// The diameter of the hour hand shaft in mm
HOUR_HAND = 5.65;

// The diameter of the 'screw' part of the shaft in mm
SHAFT = 8.2;

// The thickness of the face in mm (should be smaller than the length of your movement's screw)
FACE_THICKNESS = 2.3;

module __Customizer_Limit__ () {}  // This actually works

eps = 0.01;

center_hole_diameter_mm = MINUTE_HAND;

thickness_mm = 2.7;
square_side_mm = 160;

indicator_thickness = 15 ;

square_thickness = 3;

corner_round_mm = 2;

frame_thickness = 26;
ledge_offset = FACE_THICKNESS - 0.16;

ledge_depth = 1;

// The width of the ledge (how much it sticks out) in mm
ledge_width = 5;

$fn = $preview ? 12 : 64;

module face() {
    frame_side = square_side_mm - (square_thickness * 2);
    
    difference() {
        cube([frame_side, frame_side, FACE_THICKNESS], center = true);
        
        cylinder(h = 10, r = SHAFT/2, center = true);
    }
}

module ledge_wedge(angle = 0, length = square_side_mm) {
    
    ledge_bottom = ((frame_thickness) / 2) - ledge_offset;

    frame_side = square_side_mm - (square_thickness * 2) + 1;
    
    color("yellow")
    rotate(angle)
    //translate([-frame_side / 2 + (square_thickness / 2.7), 0, 0])
    translate([-frame_side / 2 + (square_thickness / 2) - (eps * 2), 0, ledge_bottom / sqrt(2)])
    difference() {
        cube([ledge_width, length, ledge_width], center = true);
        
        rotate([0, 45, 0]) 
        translate([sqrt(2) * 2, 0, 0])
        cube([ledge_width, length + (eps * 2), ledge_width * 2], center = true);
    }
}

module frame() {
    frame_side = square_side_mm - (square_thickness * 2);
    
    ledge_bottom = ((frame_thickness - ledge_depth) / 2) - ledge_offset;
    

    union() {
        difference() {
            // Rounded rectangle
            minkowski() {
                cube(size = [square_side_mm - corner_round_mm, square_side_mm - corner_round_mm, frame_thickness], center = true);
                sphere(r = corner_round_mm);
            }

            // Cut out the center
            cube([frame_side, frame_side, frame_thickness + 10], center = true);

            // Flatten the top
            translate([0, 0, frame_thickness - 1])
            cube(size = [square_side_mm * 2, square_side_mm * 2, frame_thickness], center = true);
            
            // Flatten the bottom
            translate([0, 0, -frame_thickness])
            cube(size = [square_side_mm * 2, square_side_mm * 2, frame_thickness], center = true);
        
        }
        
        for(a = [0:3]) {
            ledge_wedge(a * 90);
        }
    }
}

module square_hand() {
    difference() {
        union() {
            difference() {
                // Rounded rectangle
                minkowski() {
                    cube(size = [square_side_mm - corner_round_mm, square_side_mm - corner_round_mm, thickness_mm], center = true);
                    sphere(r = corner_round_mm);
                }
                
                // Cut out the center
                cube([square_side_mm - (square_thickness * 2), square_side_mm - (square_thickness * 2), thickness_mm + 10], center = true);        
            }

            // Circular bit at the bottom of the "hand"
            translate([0, -(indicator_thickness / 2) + 10, 0])
            cylinder(h = thickness_mm, r = (indicator_thickness / 2), center = true );
            
            // Rectanular "hand" that will get cut out
            translate([0, (square_side_mm / 4) + 1, 0])
            cube([indicator_thickness, (square_side_mm / 2) - 4, thickness_mm], center = true);        
        }
        
        // The "hand" cutout
        translate([0, (square_side_mm / 4) + (square_thickness / 2) + 4, 0])
        cube([indicator_thickness - (square_thickness * 2), (square_side_mm / 2 - square_thickness) + 4, thickness_mm + 1], center = true);
        
        // Flatten the top
        translate([0, 0, thickness_mm])
        cube(size = [square_side_mm * 2, square_side_mm * 2, thickness_mm], center = true);
        
        // Flatten the bottom
        translate([0, 0, -thickness_mm])
        cube(size = [square_side_mm * 2, square_side_mm * 2, thickness_mm], center = true);
    }
}


module hand_with_hole(hole_size = MINUTE_HAND) {
    difference() {
        square_hand();
        cylinder(h = thickness_mm + 1, r = hole_size / 2, center = true);
    }

}

if (PART == "hour") {
    hand_with_hole(HOUR_HAND);
} else if (PART == "minute") {
    hand_with_hole(MINUTE_HAND);
} else if (PART == "face") {
    face();
} else if (PART == "frame") {
    frame();
} else {
    ledge_z = ((frame_thickness) / 2) - ledge_offset / 2;
    
    hour_z = ledge_z + thickness_mm + 0.2;
    
    minute_z = hour_z + thickness_mm + 0.2;
    
    rotate([0, 0, 60])
    color("orange")
    translate([0, 0, minute_z])
    hand_with_hole(MINUTE_HAND);

    rotate([0, 0, -60])
    color("blue")
    translate([0, 0, hour_z])
    hand_with_hole(HOUR_HAND);

   
    color("purple")
    translate([0, 0, ledge_z])
    face();

    frame();
}