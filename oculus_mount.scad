holder_width = 17;
holder_base_length = 30;
hook_thickness = 3;
hook_length = 30;
hole_diameter = 8.2;

union() {
    cube([holder_base_length,holder_width,hook_thickness]);
    translate([30,0,0])
    rotate([0,-45,0])
    difference() {
        union(){
            cube([hook_length,holder_width,hook_thickness]);
            translate([25,0,hook_thickness/2])
            rotate([-90,0,0])
            cylinder(
                h = holder_width,
                d = hole_diameter + hook_thickness,
                $fn = 100
            );
        }
        translate([25,-holder_width/2,hook_thickness/2])
        rotate([-90,0,0])
        cylinder(
            h = holder_width*2,
            d = hole_diameter,
            $fn = 100
        );
    }
}
