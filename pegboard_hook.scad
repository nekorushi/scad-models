/* [Pegboard holes] */

// Pegboard hole diameter
hole_diameter = 6; // [1:10]

// Pegboard hole depth
hole_depth = 5; // [1:10]

/* [Pegs] */

// The distance between center points of pegboard holes ( default: 25mm)
peg_offset = 25; // [20:40]

// Rotation of pegs ( default: 0)
peg_rotation = 0; // [0:360]

// How much bigger is peg head compared to peg diameter (default: 110%)
peg_head_size_percentage = 120; // [100:150]

// How much circular is peg head, 100% = perfect sphere (default: 85%)
peg_head_depth_percentage = 85; // [50:200]

// Should first peg be L-shaped (default: true)
peg_head_cutout = true;

// How wide is cutout in a peg (default: 1.5mm)
peg_head_cutout_width = 15; // [0:30]

// How deep is cutout in a peg (default: 9mm)
peg_head_cutout_depth = 9; // [0:10]

// How much peg diameter should be reduced in relation to hole diameter (default: 20%)
peg_diameter_tolerance = 10; // [0:50]

// Should first peg be L-shaped (default: true)
first_peg_lshape = true;

// Should second peg be L-shaped (default: false)
second_peg_lshape = false;

/* [Hook base] */

// Type of a hook
hook_type="u_hook"; // [u_hook, hook_with_inserts]

// Hook thickness (default: 3)
base_thickness = 3; // [1:5]

// Hook offset (default: 0)
base_offset = 0; // [0:20]

/* [U hook] */

// Hook inner diameter (default: 15)
hook_inner_diameter = 15; // [5:50]

// Hook extension (default: true)
hook_extension = true;

// Hook extension length (default: 5)
hook_extension_length = 5; // [1:50]

/* [Hook with inserts] */

// The distance between center points of pegboard columns ( default: 25mm)
hook_inserts_pegs_offset = 25; // [20:100]

// Insert thickness (default: 3)
hook_inserts_thickness = 3; // [2:10]

// Insert segments thickness (default: 3)
hook_inserts_segment_thickness = 3; // [2:10]

// Insertion hole depth (default: 10)
hook_inserts_depth = 10; // [5:30]

// Insertion holes count (default: 1)
hook_inserts_count = 2; // [1:10]

// Insertion holes corner radius (default: 3)
hook_inserts_corner_radius = 3; // [1:10]

/* [Others] */

// Output mesh precision (default: 50)
mesh_precision = 100; // [3:200]

// Helper variables
peg_diameter = hole_diameter * (100 - peg_diameter_tolerance)/100;
peg_sphere_size = peg_diameter * peg_head_size_percentage/100;
peg_depth_multiplier = peg_head_depth_percentage/100;
peg_sphere_depth = peg_sphere_size * peg_depth_multiplier;
sphere_center_position = hole_depth + peg_sphere_depth / 2;

base_width = peg_diameter;
base_length = base_offset + peg_offset + base_width / 2;

cutout_width = peg_head_cutout_width / 10;

// Run
union() {
    create_peg_column();
    if (hook_type == "u_hook") {
        create_u_hook();
    }
    if (hook_type == "hook_with_inserts") {
        translate([-base_width/2,-base_thickness,0])
            cube([base_length+base_width/2,base_thickness,hook_inserts_pegs_offset]);
        create_peg_column([0,0,hook_inserts_pegs_offset]);
        create_inserts_hook();
    }
}

module create_peg_column(position = [0,0,0]) {
    translate(position)
    union(){
        create_peg(
            lshape = first_peg_lshape
        );
        create_peg(
            position = [peg_offset,0,0],
            lshape = second_peg_lshape
        );
        create_base();
    }
}

module create_peg(position = [0,0,0], lshape = true) { 
    translate(position)   
    rotate([-90,peg_rotation,0])
    difference(){
        union() {
                cylinder(
                    sphere_center_position,
                    d = peg_diameter,
                    $fn = mesh_precision
                );
            if (lshape) {  
                translate([0,0,sphere_center_position])
                    sphere(d = peg_diameter, $fn = mesh_precision);
                translate([0,0,sphere_center_position])
                rotate([0,-90,0])
                    cylinder(
                        peg_diameter,
                        d = peg_diameter,
                        $fn = mesh_precision
                    );
                translate([-peg_diameter,0,sphere_center_position])
                    sphere(d = peg_diameter, $fn = mesh_precision);
            } else {
                create_peg_head([0,0,sphere_center_position]);
            }
        }
        if(peg_head_cutout) {
            translate([
                -cutout_width/2,
                -peg_sphere_depth,
                hole_depth + peg_sphere_depth - peg_head_cutout_depth
            ])
                cube([
                    cutout_width,
                    peg_sphere_depth*2,
                    peg_head_cutout_depth + 1
                ]);
        }
    }
}

module create_peg_head(position = [0,0,0]) {   
    difference() {
        translate(position)
            scale([1,1,peg_depth_multiplier])
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
    
    create_arc([base_length,0,0], hook_width, inner_diameter, outer_diameter);    
    if (hook_extension) {
        translate([base_length-hook_extension_length,-outer_diameter,-hook_width/2])
            cube([hook_extension_length,base_thickness,hook_width]);
    }
}
module create_inserts_hook() {
    base_overlap = 0.1;
    translate([base_length - hook_inserts_thickness, base_overlap-base_thickness, -peg_diameter/2])
    rotate([180,-90,0])
    difference(){
        create_rounded_rectangle(
            corners = [0,0,3,3],
            size = [
                hook_inserts_pegs_offset + peg_diameter,
                base_overlap + hook_inserts_segment_thickness * (hook_inserts_count + 1) + hook_inserts_depth * hook_inserts_count,
                hook_inserts_thickness
            ]
        );
        translate([0,hook_inserts_segment_thickness,0])
        for(i = [0 : hook_inserts_count - 1]){
            translate([
                peg_diameter/2,
                i * (hook_inserts_depth + hook_inserts_segment_thickness),
                -base_overlap
            ])
            create_rounded_rectangle(
                corners = [hook_inserts_corner_radius, hook_inserts_corner_radius, hook_inserts_corner_radius, hook_inserts_corner_radius],
                size = [
                    hook_inserts_pegs_offset, 
                    hook_inserts_depth, 
                    hook_inserts_thickness + base_overlap*2
                ]);
            }
    }
}

module create_rounded_rectangle(corners = [1,1,1,1], size = [10,10,10]) {
    difference() {
        cube([size.x, size.y, size.z]);
        create_corner_negative(r = corners[0], h = size.z);
        translate([size.x, 0, 0])
        rotate([0,0,90])
            create_corner_negative(r = corners[1], h = size.z);
        translate([0, size.y, 0])
        rotate([0,0,270])
            create_corner_negative(r = corners[2], h = size.z);
        translate([size.x, size.y, 0])
        rotate([0,0,180])
            create_corner_negative(r = corners[3], h = size.z);
    }

}

module create_corner_negative(position = [0,0,0], r = 1, h = 2) {
    overlap_threshold = 0.1;
    translate(position)
    difference() {
        translate([-overlap_threshold,-overlap_threshold,-overlap_threshold])
        cube([r+overlap_threshold,r+overlap_threshold,h+overlap_threshold*2]);  
        translate([r,r,-overlap_threshold])
        cylinder(
            h = h + overlap_threshold*2,
            r = r,
            $fn = mesh_precision
        );
    }
}

module create_arc(begin_pos = [0,0,0], width, inner_diameter, outer_diameter) {
    arc_center = begin_pos + [0,-outer_diameter/2,-width/2];
    rotation = [0,0,90]; // For fitting of a hook with base
    diff_threshold = 0.1;
    difference() {
        translate(arc_center)
        rotate(rotation)
            cylinder(
                h = width,
                d = outer_diameter,
                $fn = mesh_precision
            );
        
        translate(arc_center + [0,0,-diff_threshold/2])
        rotate(rotation)
            cylinder(
                h = width + diff_threshold,
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
                width + diff_threshold * 2]
            );
    }
}