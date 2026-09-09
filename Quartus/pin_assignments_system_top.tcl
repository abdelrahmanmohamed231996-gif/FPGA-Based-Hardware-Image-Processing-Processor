# =====================================================
# pin_assignments_system_top.tcl
# DE10-Standard - system_top (full conv pipeline + VGA + PLL)
#
# Assumes system_top.v has been updated so that:
#   - vga_clk_in (input) is REMOVED
#   - vga_clk_out (output) is ADDED, driven from the PLL
#   - PLL is instantiated internally (refclk = clk)
#
# Run from Quartus Tcl Console:  source pin_assignments_system_top.tcl
# Assumes project is already open (project_open <name>)
# =====================================================

package require ::quartus::project

set project_name "system_top"

if {[is_project_open] == 0} {
    project_open $project_name
} else {
    puts "Project already open."
}

# -----------------------------------------------------
# Clock & Reset
# -----------------------------------------------------
set_location_assignment PIN_AF14 -to clk      ;# CLOCK_50 - feeds pipeline AND PLL refclk
set_location_assignment PIN_AJ4  -to rst_n    ;# KEY0

# -----------------------------------------------------
# Filter Select Switches
# -----------------------------------------------------
set_location_assignment PIN_AB30 -to filter0_sel    ;# SW0
set_location_assignment PIN_Y27  -to filter1_sel    ;# SW1
set_location_assignment PIN_AB28 -to filter2_sel    ;# SW2

# -----------------------------------------------------
# VGA Sync / Control
# -----------------------------------------------------
set_location_assignment PIN_AK19 -to h_sync          ;# VGA_HS
set_location_assignment PIN_AK18 -to v_sync          ;# VGA_VS
set_location_assignment PIN_AK22 -to vga_blank_N      ;# VGA_BLANK_N
set_location_assignment PIN_AJ22 -to vga_sync_N       ;# VGA_SYNC_N
set_location_assignment PIN_AK21 -to vga_clk_out      ;# VGA_CLK (now driven by PLL)

# v_on has no dedicated board net; routed to a spare LED for
# visual debug (lit = currently inside active display window)
set_location_assignment PIN_AC22 -to v_on             ;# LEDR9 (debug only)

# -----------------------------------------------------
# VGA RGB Output
# -----------------------------------------------------
set_location_assignment PIN_AK29 -to {r[0]}
set_location_assignment PIN_AK28 -to {r[1]}
set_location_assignment PIN_AK27 -to {r[2]}
set_location_assignment PIN_AJ27 -to {r[3]}
set_location_assignment PIN_AH27 -to {r[4]}
set_location_assignment PIN_AF26 -to {r[5]}
set_location_assignment PIN_AG26 -to {r[6]}
set_location_assignment PIN_AJ26 -to {r[7]}

set_location_assignment PIN_AK26 -to {g[0]}
set_location_assignment PIN_AJ25 -to {g[1]}
set_location_assignment PIN_AH25 -to {g[2]}
set_location_assignment PIN_AK24 -to {g[3]}
set_location_assignment PIN_AJ24 -to {g[4]}
set_location_assignment PIN_AH24 -to {g[5]}
set_location_assignment PIN_AK23 -to {g[6]}
set_location_assignment PIN_AH23 -to {g[7]}

set_location_assignment PIN_AJ21 -to {b[0]}
set_location_assignment PIN_AJ20 -to {b[1]}
set_location_assignment PIN_AH20 -to {b[2]}
set_location_assignment PIN_AJ19 -to {b[3]}
set_location_assignment PIN_AH19 -to {b[4]}
set_location_assignment PIN_AJ17 -to {b[5]}
set_location_assignment PIN_AJ16 -to {b[6]}
set_location_assignment PIN_AK16 -to {b[7]}

# -----------------------------------------------------
# I/O Standard = 3.3V for all assigned pins
# -----------------------------------------------------
set io_pins {
    clk rst_n
    filter0_sel filter1_sel filter2_sel
    h_sync v_sync v_on vga_blank_N vga_sync_N vga_clk_out
    r[0] r[1] r[2] r[3] r[4] r[5] r[6] r[7]
    g[0] g[1] g[2] g[3] g[4] g[5] g[6] g[7]
    b[0] b[1] b[2] b[3] b[4] b[5] b[6] b[7]
}

foreach pin $io_pins {
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to $pin
}

# -----------------------------------------------------
# Save & Close
# -----------------------------------------------------
export_assignments
puts "Pin assignments applied successfully for system_top (PLL-based VGA clock)."

if {[is_project_open]} {
    project_close
}
