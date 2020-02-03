/* [Screw holes] */

// Screw hole diameter (100 = 1mm)
screw_hole_diameter = 325; // [100:800]

// Distance between left/right edges and centers of screw holes (100 = 1mm)
screw_hole_horizontal_dist = 500; // [200:2000]

// Distance between top/bottom edges and centers of screw holes (100 = 1mm)
screw_hole_vertical_dist = 500; // [200:2000]

/* [Base plate] */

// Base plate width
plate_width = 128; // [50:300]

// Base plate height
plate_height = 88; // [50:300]

// Base plate thickness
plate_thickness = 2; // [1:10]

// Base plate rounded coners
plate_rounded_corners = true;

/* [Vent] */

// Vent base base diameter
vent_base_diameter = 65; // [20:150]

// Vent base length
vent_base_length = 10; // [5:150]

// Vent tip thickness
vent_tip_thickness = 2; // [1:10]

// Vent tip inner diameter
vent_tip_diameter = 32; // [20:150]

// Vent tip bend angle
vent_tip_angle = 70; // [0:90]

// Vent tip length
vent_tip_length = 20; // [0:100]

/* [Others] */

// Output mesh precision (default: 50)
mesh_precision = 100; // [3:200]
diff_threshold = 0.01;

main();

module main() {
    vent_base_position = [
        plate_width / 2,
        plate_height / 2,
        plate_thickness
    ];
    
    union() {    
        difference() {        
            union() {
                create_base(dimensions = [
                    plate_width,
                    plate_height,
                    plate_thickness
                ]);
                
                create_funnel(
                    vent_base_position,
                    h = vent_base_length,
                    d1 = vent_base_diameter + vent_tip_thickness*2,
                    d2 = vent_tip_diameter + vent_tip_thickness*2,
                    bottom_thickness = plate_thickness
                );
            }
            create_funnel(
                vent_base_position - [0,0,plate_thickness],
                h = vent_base_length,
                d1 = vent_base_diameter,
                d2 = vent_tip_diameter,
               bottom_thickness = 10,
                top_thickness = 10
            );
        }
        create_bent_pipe(
            position = vent_base_position + [0,0,vent_base_length],
            d = vent_tip_diameter,
            thickness = vent_tip_thickness,
            angle = vent_tip_angle,
            extension = vent_tip_length
        );
    }
}

module create_base(position = [0,0,0], dimensions) {
    width = dimensions[0];
    height = dimensions[1];
    thickness = dimensions[2];
    screw_horizontal_dist = screw_hole_horizontal_dist / 100;
    screw_vertical_dist = screw_hole_vertical_dist / 100;
    
    corners_compensation = plate_rounded_corners ? [
        screw_horizontal_dist,
        screw_vertical_dist,
        0
    ] : [0,0,0];
    
    bottom_left_hole_pos = [screw_horizontal_dist, screw_vertical_dist, 0];
    bottom_right_hole_pos = [width - screw_horizontal_dist, screw_vertical_dist, 0];
    top_left_hole_pos = [screw_horizontal_dist, height - screw_vertical_dist, 0];
    top_right_hole_pos = [width - screw_horizontal_dist, height - screw_vertical_dist, 0];
    
    translate(position)
    difference() {
           
        hull() {
            translate(corners_compensation)
            cube(dimensions - corners_compensation*2);   
            
            if (plate_rounded_corners) {                
                create_hole_mesh(bottom_left_hole_pos, false, 1000);
                create_hole_mesh(bottom_right_hole_pos, false, 1000);
                create_hole_mesh(top_left_hole_pos, false, 1000);
                create_hole_mesh(top_right_hole_pos, false, 1000);
            }
        }
        
        create_hole_mesh(bottom_left_hole_pos);            
        create_hole_mesh(bottom_right_hole_pos);
        create_hole_mesh(top_left_hole_pos);            
        create_hole_mesh(top_right_hole_pos);
    }
}


module create_hole_mesh(position = [0,0,0], compensate = true, diameter = 0) {
    compensation = compensate ? diff_threshold : 0;
    hole_diameter = diameter > 0 ? diameter : screw_hole_diameter;
    translate(position + [0,0,-compensation])
    cylinder(
        h = plate_thickness + 2*compensation,
        d = hole_diameter / 100,
        $fn = mesh_precision
    );
}



module create_funnel(position, h, d1, d2, bottom_thickness = 0, top_thickness = 0){
    translate(position)
    union() {
        cylinder(h = h, d1 = d1, d2 = d2);
        if (top_thickness > 0) {
            translate([0,0,h-diff_threshold])
            cylinder(h = top_thickness+diff_threshold, d = d2);
        }
        if (bottom_thickness > 0) {
            translate([0,0,-bottom_thickness])
            cylinder(h = bottom_thickness+diff_threshold, d = d1);
        }
    }    
}

module create_pipe(h, d, thickness) {
    linear_extrude(h)
    difference() {
        circle(d = d + thickness*2, $fn = mesh_precision);
        circle(d = d, $fn = mesh_precision);
    }
}

module create_bent_pipe(position, d, thickness, angle = 90, extension = 0) {
    radius = d/2 + thickness;
    translate(position + [0,radius,0])
    rotate([90,-angle,-90])
    union() {
        if (extension > 0) {
            translate([radius,0,0])
            rotate([0 -90,-90,0])
            create_pipe(extension, d, thickness);
        }        
        rotate([0,0,-angle])
        rotate_extrude(angle = angle, convexity = 10)
        translate([radius, 0, 0])
        difference() {
            circle(d = d + thickness*2, $fn = mesh_precision);
            circle(d = d, $fn = mesh_precision);
        }
    }
}

