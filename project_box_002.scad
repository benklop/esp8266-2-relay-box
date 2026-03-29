// project_box_002.scad
// Project box for 47×78mm PCB
// Mounting holes: 40mm (W) × 70mm (L) pattern, M3 heat-set inserts
// Terminal openings: 30.5mm (+Y/A end), 15.5mm (−Y/B end)
// Mounting tabs on ±X sides
// Matching lid with countersunk M3 holes
//
// Set PART to "box" or "lid" before printing/exporting

PART = "box";   // "box" or "lid"

$fn = 48;

// ── PCB ────────────────────────────────────────────────────────
pcb_w     = 47;      // PCB width (X axis)
pcb_l     = 78;      // PCB length (Y axis)
hole_w    = 40;      // mounting hole spacing, X
hole_l    = 70;      // mounting hole spacing, Y

// ── Box geometry ───────────────────────────────────────────────
wall      = 2;       // wall thickness
floor_t   = 3;       // floor thickness (supports heat-set inserts)
gap       = 1.5;     // clearance around PCB each side
inner_w   = pcb_w + 2*gap;    // 50 mm
inner_l   = pcb_l + 2*gap;    // 81 mm
inner_h   = 25;      // inner box height
outer_w   = inner_w + 2*wall;  // 54 mm
outer_l   = inner_l + 2*wall;  // 85 mm
outer_h   = inner_h + floor_t; // 28 mm

// ── M3 heat-set inserts / bosses ───────────────────────────────
// Hole positions: ±20mm (X) and ±35mm (Y) from box centre
// Inner wall at ±25mm (X) — boss OD=7 gives 1.5mm clearance ✓
ins_d     = 4.2;     // M3 heat-set insert hole diameter
ins_dep   = 5.0;     // insert hole depth (1mm solid bottom remains)
boss_od   = 7;       // boss outer diameter (7-4.2)/2 = 1.4mm wall ✓
boss_h    = 3;       // boss height above floor
// Clearance from boss edge to inner wall: 25-20-3.5 = 1.5mm (X)
//                                         40.5-35-3.5 = 2mm  (Y)

// ── Terminal openings ──────────────────────────────────────────
term_a    = 30.5;    // opening at +Y end (centred)
term_b    = 15.5;    // opening at −Y end (centred)
term_bot  = 3;       // solid strip at bottom before opening

// ── Mounting tabs ──────────────────────────────────────────────
tab_ext   = 10;      // extension beyond box wall
tab_len   = 22;      // length along Y (centred on box)
tab_t     = 4;       // thickness — slightly thicker for strength
tab_hole  = 3.5;     // M3 clearance hole

// ── Lid ────────────────────────────────────────────────────────
lid_t     = 2.5;     // lid plate thickness
lip_wall  = 1.5;     // lip wall thickness
lip_h     = 3;       // lip depth (fits inside box)
lip_gap   = 0.3;     // radial clearance lip ↔ inner wall
cs_top_d  = 6.0;     // countersink top diameter (M3 flat head)
cs_bot_d  = 3.4;     // through-hole / countersink base diameter
cs_dep    = 2.0;     // countersink depth

// ── Derived ────────────────────────────────────────────────────
lip_ow    = inner_w - 2*lip_gap;   // 49.4 mm
lip_ol    = inner_l - 2*lip_gap;   // 80.4 mm
lip_iw    = lip_ow - 2*lip_wall;   // 46.4 mm
lip_il    = lip_ol - 2*lip_wall;   // 77.4 mm

// ═══════════════════════════════════════════════════════════════
// Modules
// ═══════════════════════════════════════════════════════════════

// Boss with heat-set insert hole, placed at (x,y,0).
// Runs Z=0 → floor_t+boss_h; insert opens at boss top (inside box).
module boss_insert() {
    difference() {
        cylinder(d=boss_od, h=floor_t + boss_h);
        translate([0, 0, floor_t + boss_h - ins_dep])
            cylinder(d=ins_d, h=ins_dep + 0.01);
    }
}

// Flat mounting tab with M3 hole (Z-axis, suits surface/bottom mount)
module tab_shape() {
    difference() {
        // Rounded outer corners via hull
        hull() {
            translate([0, 3, 0])     cube([tab_ext - 3, tab_len - 6, tab_t]);
            translate([tab_ext-3, 3, 0]) cylinder(r=3, h=tab_t);
            translate([tab_ext-3, tab_len-3, 0]) cylinder(r=3, h=tab_t);
        }
        // M3 clearance hole centred in tab
        translate([tab_ext/2, tab_len/2, -0.01])
            cylinder(d=tab_hole, h=tab_t + 0.02);
    }
}

// ── Project box ───────────────────────────────────────────────
module project_box() {
    union() {
        difference() {
            union() {
                // Box body (centred in X/Y, Z=0 at bottom)
                translate([-outer_w/2, -outer_l/2, 0])
                    cube([outer_w, outer_l, outer_h]);

                // Left mounting tab  (−X side)
                translate([-outer_w/2 - tab_ext, -tab_len/2, 0])
                    tab_shape();

                // Right mounting tab (+X side)
                translate([outer_w/2, -tab_len/2, 0])
                    tab_shape();
            }

            // Hollow out interior
            translate([-inner_w/2, -inner_l/2, floor_t])
                cube([inner_w, inner_l, inner_h + 1]);

            // Terminal opening: +Y end (30.5 mm, centred)
            translate([-term_a/2, outer_l/2 - wall - 0.01, term_bot])
                cube([term_a, wall + 0.02, outer_h - term_bot + 0.01]);

            // Terminal opening: −Y end (15.5 mm, centred)
            translate([-term_b/2, -outer_l/2 - 0.01, term_bot])
                cube([term_b, wall + 0.02, outer_h - term_bot + 0.01]);
        }

        // PCB mounting bosses (added after difference to preserve insert holes)
        for (x = [-hole_w/2, hole_w/2])
            for (y = [-hole_l/2, hole_l/2])
                translate([x, y, 0])
                    boss_insert();
    }
}

// ── Lid ───────────────────────────────────────────────────────
// Sits on top of box; locating lip fits inside box opening.
// Screw path: lid CS hole → standoff → heat-set insert in boss.
module lid() {
    difference() {
        union() {
            // Lid plate
            translate([-outer_w/2, -outer_l/2, 0])
                cube([outer_w, outer_l, lid_t]);

            // Locating lip (hangs down into box)
            translate([-lip_ow/2, -lip_ol/2, -lip_h])
                difference() {
                    cube([lip_ow, lip_ol, lip_h]);
                    translate([lip_wall, lip_wall, -0.01])
                        cube([lip_iw, lip_il, lip_h + 0.02]);
                }
        }

        // Countersunk M3 holes aligned with PCB mounting holes
        for (x = [-hole_w/2, hole_w/2])
            for (y = [-hole_l/2, hole_l/2])
                translate([x, y, 0]) {
                    // Through-hole (clears lip and plate)
                    translate([0, 0, -lip_h - 0.01])
                        cylinder(d=cs_bot_d, h=lid_t + lip_h + 0.02);
                    // Countersink: wider at top surface
                    translate([0, 0, lid_t - cs_dep])
                        cylinder(d1=cs_bot_d, d2=cs_top_d, h=cs_dep + 0.01);
                }
    }
}

// ═══════════════════════════════════════════════════════════════
// Render selected part
// ═══════════════════════════════════════════════════════════════

if (PART == "box") {
    project_box();
} else if (PART == "lid") {
    lid();
}
