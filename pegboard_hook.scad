/* [Pegboard holes] */

// Pegboard hole diameter
hole_diameter = 6; // [1:10]

// Pegboard hole depth
hole_depth = 5; // [1:10]

/* [Pegs] */

// The distance between center points of pegboard holes ( default: 25mm)
peg_offset = 25; // [20:40]

// How much bigger is peg head compared to peg diameter (default: 110%)
peg_head_size_percentage = 120; // [100:150]

// How much peg diameter should be reduced in relation to hole diameter (default: 20%)
peg_diameter_tolerance = 10; // [0:50]

// Should first peg be L-shaped (default: true)
first_peg_lshape = true;

// Should second peg be L-shaped (default: false)
second_peg_lshape = false;

/* [Hook base] */

// Hook thickness (default: 3)
base_thickness = 3; // [1:5]

// Hook offset (default: 0)
base_offset = 0; // [0:20]

/* [Hook] */

// Hook inner diameter (default: 15)
hook_inner_diameter = 15; // [5:50]

// Hook extension (default: true)
hook_extension = true;

// Hook extension length (default: 5);
hook_extension_length = 5; // [1:50]

/* [Others] */

// Output mesh precision (default: 50)
mesh_precision = 100; // [3:200]

// Helper variables
peg_diameter = hole_diameter * (100 - peg_diameter_tolerance)/100;
peg_sphere_size = peg_diameter * peg_head_size_percentage/100;
sphere_center_position = hole_depth + peg_sphere_size / 2;

base_width = peg_diameter;
base_length = base_offset + peg_offset + base_width / 2;


// Run
union() {
    create_peg(
        lshape = first_peg_lshape
    );
    create_peg(
        position = [peg_offset,0,0],
        lshape = second_peg_lshape
    );
    create_base();
    create_u_hook();
}

module create_peg(position = [0,0,0], lshape = true) {    
    rotate([-90,0,0])
    difference(){
        union() {
            translate(position)
                cylinder(
                    sphere_center_position,
                    d = peg_diameter,
                    $fn = mesh_precision
                );
            if (lshape) {  
                translate(position + [0,0,sphere_center_position])
                    sphere(d = peg_diameter, $fn = mesh_precision);
                translate(position + [0,0,sphere_center_position])
                rotate([0,-90,0])
                    cylinder(
                        peg_diameter,
                        d = peg_diameter,
                        $fn = mesh_precision
                    );
                translate(position + [-peg_diameter,0,sphere_center_position])
                    sphere(d = peg_diameter, $fn = mesh_precision);
            } else {
                create_peg_head(position + [0,0,sphere_center_position]);
            }
        }
    }
}

module create_peg_head(position = [0,0,0]) {   
    difference() {
        translate(position)
            sphere(d = peg_sphere_size, $fn = mesh_precision);
        
        translate(position + [0,-peg_diameter,0])
            cube(peg_diameter, true);

        translate(position + [0,peg_diameter,0])
            cube(peg_diameter, true);        
    }
}

module create_base() {
    union() {
        rotate([-90,0,0])
        translate([0,0,-base_thickness])
            cylinder(h = base_thickness, d = base_width, $fn = mesh_precision);
        
        
        translate([0,-base_thickness,-base_width/2])
            cube([base_length,base_thickness,base_width]);
    }
}
module create_u_hook() {
    inner_diameter = hook_inner_diameter;
    outer_diameter = inner_diameter + base_thickness*2;
    hook_width = peg_diameter;
    arc_center = [base_length,-outer_diameter/2,-hook_width/2];
    diff_threshold = 0.1;
    rotation = [0,0,90]; // For fitting of a hook with base
    difference(){
        translate(arc_center)
        rotate(rotation)
            cylinder(
                h = hook_width,
                d = outer_diameter,
                $fn = mesh_precision
            );
        
        translate(arc_center + [0,0,-diff_threshold/2])
        rotate(rotation)
            cylinder(
                h = hook_width + diff_threshold,
                d = inner_diameter,
                $fn = mesh_precision
            );
        
        translate(arc_center + [
            -(outer_diameter / 2 + diff_threshold),
            -(outer_diameter / 2 + diff_threshold),
            -diff_threshold
        ])
            cube([
                outer_diameter / 2 + diff_threshold,
                outer_diameter + diff_threshold * 2,
                hook_width + diff_threshold * 2]
            );
    }
    
    if (hook_extension) {
        translate([base_length-hook_extension_length,-outer_diameter,-hook_width/2])
            cube([hook_extension_length,base_thickness,hook_width]);
    }
}