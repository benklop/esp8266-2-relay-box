// project_box_008.scad
// Project box for 47×78mm PCB
// Mounting holes: 40mm (W) × 70mm (L) pattern, M3 heat-set inserts
// Terminal openings: 30.5mm (+Y/A end), 15.5mm (−Y/B end)
//   — openings start at PCB top surface height
// Mounting tabs on ±X sides
// Lid (printed flat-face-down): locating lip + tongues that fill
//   terminal openings from top, leaving 10.5mm open at bottom
//
// Set PART to "box" or "lid" before printing/exporting

PART = "box";   // "box" or "lid"

$fn = 48;

// ── PCB ────────────────────────────────────────────────────────
pcb_w      = 47;     // PCB width (X axis)
pcb_l      = 78;     // PCB length (Y axis)
hole_w     = 40;     // mounting hole spacing, X
hole_l     = 70;     // mounting hole spacing, Y

// ── Box geometry ───────────────────────────────────────────────
wall       = 2;      // wall thickness
floor_t    = 3;      // floor thickness (supports heat-set inserts)
gap        = 1.5;    // clearance around PCB each side
inner_w    = pcb_w + 2*gap;    // 50 mm
inner_l    = pcb_l + 2*gap;    // 81 mm
outer_w    = inner_w + 2*wall;  // 54 mm
outer_l    = inner_l + 2*wall;  // 85 mm

// ── M3 heat-set inserts / bosses (M3×0.5, H=3mm, Φd₁=4.5mm) ──
// Insert Φd₁ = 4.5mm (outer knurled OD)
// Recommended hole = Φd₁ + 0.1mm (per manufacturer spec on insert packaging)
// Hole depth = 1.5× insert length per Hackaday guide (room for displaced plastic)
// Boss wall = (boss_od - ins_d) / 2 ≥ 1.6mm (4 perimeters @ 0.4mm nozzle)
ins_d      = 4.6;    // Φd₁(4.5mm) + 0.1mm per manufacturer recommendation
ins_dep    = 4.5;    // 1.5 × 3mm insert length; displaced plastic goes below
ins_taper  = 0.8;    // entry chamfer depth — guides insert into hole before heat
ins_taper_d = ins_d + 1.0; // chamfer top Ø (0.5mm wider each side)
boss_od    = 8;      // (8-4.6)/2 = 1.7mm wall ≈ 4 perimeters; 1mm clear to inner wall
boss_h     = 3;      // boss height = insert length → insert sits flush with boss top

// ── PCB stack ──────────────────────────────────────────────────
// PCB sits directly on boss tops; M3 screws through PCB into inserts.
// No separate standoffs between boss and PCB — only FR4 thickness gap.
pcb_t      = 1.6;   // standard FR4 PCB thickness

// Heights from box floor:
pcb_bot_z  = floor_t + boss_h;   // 6mm  — PCB rests on boss tops
pcb_top_z  = pcb_bot_z + pcb_t;  // 7.6mm — PCB top / component base

// Inner height = clearance above PCB top (component space)
inner_h    = 18;     // 17mm components + 1mm headroom
outer_h    = pcb_top_z + inner_h;  // 25.6mm total box height

// ── Terminal openings ──────────────────────────────────────────
// Openings start at PCB top surface so wires exit at board level
term_bot   = pcb_top_z;   // ≈ 12.6mm from box bottom
term_a     = 30.5;   // +Y end opening width (centred)
term_b     = 15.5;   // −Y end opening width (centred)

// ── Mounting tabs ──────────────────────────────────────────────
tab_ext    = 10;     // extension beyond box wall
tab_len    = 22;     // length along Y (centred on box)
tab_t      = 4;      // tab thickness
tab_hole   = 3.5;    // M3 clearance hole

// ── Lid ────────────────────────────────────────────────────────
// Printed flat-face-down (Z=0 = exterior/smooth face on print bed).
// Features (lip, tongues, countersinks) are on the interior face
// at Z=lid_t and extend upward in print orientation.
lid_t      = 2.5;    // lid plate thickness
lip_wall   = 1.5;    // locating lip wall thickness
lip_h      = 3;      // locating lip depth
lip_gap    = 0.3;    // radial clearance lip ↔ inner wall

// Terminal opening info (also used for tongue sizing)
open_h     = outer_h - term_bot;    // full opening height = 18mm
tongue_h   = open_h - 10.5;        // tongue fills top; leaves 10.5mm open
tongue_clr = 0.3;                   // tongue-to-slot clearance each side

cs_top_d   = 6.0;    // countersink top Ø (M3 flat head)
cs_bot_d   = 3.4;    // M3 clearance hole
cs_dep     = 2.0;    // countersink depth

// ── Derived ────────────────────────────────────────────────────
lip_ow     = inner_w - 2*lip_gap;
lip_ol     = inner_l - 2*lip_gap;
lip_iw     = lip_ow - 2*lip_wall;
lip_il     = lip_ol - 2*lip_wall;

tongue_a_w = term_a - 2*tongue_clr;   // +Y tongue width
tongue_b_w = term_b - 2*tongue_clr;   // −Y tongue width
tongue_d   = wall   - tongue_clr;     // tongue depth (fits in wall slot)

// ═══════════════════════════════════════════════════════════════
// Modules
// ═══════════════════════════════════════════════════════════════

// Boss with heat-set insert hole, placed at (x,y,0).
// Runs Z=0 → floor_t+boss_h; insert opens at boss top (inside box).
// Entry chamfer guides insert for hand-installation before applying heat.
module boss_insert() {
    boss_top = floor_t + boss_h;
    difference() {
        cylinder(d=boss_od, h=boss_top);
        // Straight bore (undersized; insert displaces plastic into knurls)
        translate([0, 0, boss_top - ins_dep])
            cylinder(d=ins_d, h=ins_dep + 0.01);
        // Entry chamfer at boss top: guides insert before pressing with iron
        translate([0, 0, boss_top - ins_taper])
            cylinder(d1=ins_d, d2=ins_taper_d, h=ins_taper + 0.01);
    }
}

// Flat mounting tab with rounded outer corners and M3 clearance hole
module tab_shape() {
    difference() {
        hull() {
            translate([0, 3, 0])        cube([tab_ext - 3, tab_len - 6, tab_t]);
            translate([tab_ext-3, 3, 0])     cylinder(r=3, h=tab_t);
            translate([tab_ext-3, tab_len-3, 0]) cylinder(r=3, h=tab_t);
        }
        translate([tab_ext/2, tab_len/2, -0.01])
            cylinder(d=tab_hole, h=tab_t + 0.02);
    }
}

// ── Project box ───────────────────────────────────────────────
module project_box() {
    union() {
        difference() {
            union() {
                translate([-outer_w/2, -outer_l/2, 0])
                    cube([outer_w, outer_l, outer_h]);
                // Left mounting tab (−X side) — mirrored so rounded end faces out
                translate([-outer_w/2, -tab_len/2, 0])
                    mirror([1, 0, 0])
                    tab_shape();
                // Right mounting tab (+X side)
                translate([outer_w/2, -tab_len/2, 0])
                    tab_shape();
            }
            // Interior cavity (full height from floor to top)
            translate([-inner_w/2, -inner_l/2, floor_t])
                cube([inner_w, inner_l, outer_h - floor_t + 1]);
            // Terminal opening: +Y end (30.5mm, starts at PCB top level)
            translate([-term_a/2, outer_l/2 - wall - 0.01, term_bot])
                cube([term_a, wall + 0.02, outer_h - term_bot + 0.01]);
            // Terminal opening: −Y end (15.5mm, starts at PCB top level)
            translate([-term_b/2, -outer_l/2 - 0.01, term_bot])
                cube([term_b, wall + 0.02, outer_h - term_bot + 0.01]);
        }
        // PCB mounting bosses
        for (x = [-hole_w/2, hole_w/2])
            for (y = [-hole_l/2, hole_l/2])
                translate([x, y, 0])
                    boss_insert();
    }
}

// ── Lid ───────────────────────────────────────────────────────
// PRINT ORIENTATION: Z=0 face (exterior, smooth) on print bed.
// Assemble by flipping over — exterior face becomes the visible top.
//
// In assembled position (flipped over from print orientation):
//   • Exterior face (Z=0 in SCAD) is UP / visible
//   • Countersinks on exterior face — screw heads flush with outside
//   • Locating lip + tongues hang DOWN into box
module lid() {
    difference() {
        union() {
            // Lid plate
            translate([-outer_w/2, -outer_l/2, 0])
                cube([outer_w, outer_l, lid_t]);

            // Locating lip (extends from interior face, constrains X+Y)
            translate([-lip_ow/2, -lip_ol/2, lid_t])
                difference() {
                    cube([lip_ow, lip_ol, lip_h]);
                    translate([lip_wall, lip_wall, -0.01])
                        cube([lip_iw, lip_il, lip_h + 0.02]);
                }

            // Tongue: +Y end — slides into 30.5mm terminal opening
            translate([-tongue_a_w/2, outer_l/2 - tongue_d, lid_t])
                cube([tongue_a_w, tongue_d, tongue_h]);

            // Tongue: −Y end — slides into 15.5mm terminal opening
            translate([-tongue_b_w/2, -outer_l/2, lid_t])
                cube([tongue_b_w, tongue_d, tongue_h]);
        }

        // Countersinks on exterior face (Z=0), screw head flush on top
        for (x = [-hole_w/2, hole_w/2])
            for (y = [-hole_l/2, hole_l/2])
                translate([x, y, 0]) {
                    // Countersink: wider at Z=0 (exterior)
                    cylinder(d1=cs_top_d, d2=cs_bot_d, h=cs_dep + 0.01);
                    // Through-hole continues into lip/tongue zone
                    translate([0, 0, cs_dep - 0.01])
                        cylinder(d=cs_bot_d, h=lid_t + lip_h + 0.02);
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
