# Copyright (C) 2025  Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and any partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, the Altera Quartus Prime License Agreement,
# the Altera IP License Agreement, or other applicable license
# agreement, including, without limitation, that your use is for
# the sole purpose of programming logic devices manufactured by
# Altera and sold by Altera or its authorized distributors.  Please
# refer to the Altera Software License Subscription Agreements 
# on the Quartus Prime software download page.

# Quartus Prime: Generate Tcl File for Project
# File: 2d_conv.tcl
# Generated on: Wed Sep  9 10:42:46 2026

# Load Quartus Prime Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "2d_conv"]} {
		puts "Project 2d_conv is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists 2d_conv]} {
		project_open -revision 2d_conv 2d_conv
	} else {
		project_new -revision 2d_conv 2d_conv
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "Cyclone V"
	set_global_assignment -name DEVICE 5CSXFC6D6F31C6
	set_global_assignment -name TOP_LEVEL_ENTITY system_top
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 25.1STD.0
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "08:58:18  SEPTEMBER 09, 2026"
	set_global_assignment -name LAST_QUARTUS_VERSION "25.1std.0 Lite Edition"
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 256
	set_global_assignment -name EDA_SIMULATION_TOOL "Questa Altera FPGA (Verilog)"
	set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT "VERILOG HDL" -section_id eda_simulation
	set_global_assignment -name EDA_GENERATE_FUNCTIONAL_NETLIST OFF -section_id eda_board_design_timing
	set_global_assignment -name EDA_GENERATE_FUNCTIONAL_NETLIST OFF -section_id eda_board_design_symbol
	set_global_assignment -name EDA_GENERATE_FUNCTIONAL_NETLIST OFF -section_id eda_board_design_signal_integrity
	set_global_assignment -name EDA_GENERATE_FUNCTIONAL_NETLIST OFF -section_id eda_board_design_boundary_scan
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_global_assignment -name VERILOG_FILE ../rtl/pll.v
	set_global_assignment -name VERILOG_FILE ../rtl/pll/pll_0002.v
	set_global_assignment -name SOURCE_FILE mem_files/outline.mem
	set_global_assignment -name SOURCE_FILE mem_files/image.mem
	set_global_assignment -name SOURCE_FILE mem_files/identify.mem
	set_global_assignment -name SOURCE_FILE mem_files/emboss.mem
	set_global_assignment -name SOURCE_FILE mem_files/dual_port_ram.mem
	set_global_assignment -name SOURCE_FILE mem_files/bottom_sobel.mem
	set_global_assignment -name VERILOG_FILE rtl/window_gen.v
	set_global_assignment -name VERILOG_FILE rtl/vga_controller.v
	set_global_assignment -name VERILOG_FILE rtl/system_top.v
	set_global_assignment -name VERILOG_FILE rtl/signed_multiply_with_input_and_output_registers.v
	set_global_assignment -name VERILOG_FILE rtl/signed_adder_subtractor.v
	set_global_assignment -name VERILOG_FILE rtl/output_if.v
	set_global_assignment -name VERILOG_FILE rtl/output_assembly.v
	set_global_assignment -name VERILOG_FILE rtl/mac_mult_array.v
	set_global_assignment -name VERILOG_FILE rtl/kernel_regs.v
	set_global_assignment -name VERILOG_FILE rtl/in9_reg.v
	set_global_assignment -name VERILOG_FILE rtl/image_bram.v
	set_global_assignment -name VERILOG_FILE rtl/frame_buffer.v
	set_global_assignment -name VERILOG_FILE rtl/conv_top.v
	set_global_assignment -name VERILOG_FILE rtl/addr_gen.v
	set_global_assignment -name VERILOG_FILE rtl/adder_tree.v
	set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
	set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
	set_location_assignment PIN_AF14 -to clk
	set_location_assignment PIN_AJ4 -to rst_n
	set_location_assignment PIN_AB30 -to filter0_sel
	set_location_assignment PIN_Y27 -to filter1_sel
	set_location_assignment PIN_AB28 -to filter2_sel
	set_location_assignment PIN_AK19 -to h_sync
	set_location_assignment PIN_AK18 -to v_sync
	set_location_assignment PIN_AK22 -to vga_blank_N
	set_location_assignment PIN_AJ22 -to vga_sync_N
	set_location_assignment PIN_AK21 -to vga_clk_out
	set_location_assignment PIN_AC22 -to v_on
	set_location_assignment PIN_AK29 -to r[0]
	set_location_assignment PIN_AK28 -to r[1]
	set_location_assignment PIN_AK27 -to r[2]
	set_location_assignment PIN_AJ27 -to r[3]
	set_location_assignment PIN_AH27 -to r[4]
	set_location_assignment PIN_AF26 -to r[5]
	set_location_assignment PIN_AG26 -to r[6]
	set_location_assignment PIN_AJ26 -to r[7]
	set_location_assignment PIN_AK26 -to g[0]
	set_location_assignment PIN_AJ25 -to g[1]
	set_location_assignment PIN_AH25 -to g[2]
	set_location_assignment PIN_AK24 -to g[3]
	set_location_assignment PIN_AJ24 -to g[4]
	set_location_assignment PIN_AH24 -to g[5]
	set_location_assignment PIN_AK23 -to g[6]
	set_location_assignment PIN_AH23 -to g[7]
	set_location_assignment PIN_AJ21 -to b[0]
	set_location_assignment PIN_AJ20 -to b[1]
	set_location_assignment PIN_AH20 -to b[2]
	set_location_assignment PIN_AJ19 -to b[3]
	set_location_assignment PIN_AH19 -to b[4]
	set_location_assignment PIN_AJ17 -to b[5]
	set_location_assignment PIN_AJ16 -to b[6]
	set_location_assignment PIN_AK16 -to b[7]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to clk
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to rst_n
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to filter0_sel
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to filter1_sel
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to filter2_sel
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to h_sync
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to v_sync
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to v_on
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to vga_blank_N
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to vga_sync_N
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to vga_clk_out
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to r[0]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to r[1]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to r[2]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to r[3]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to r[4]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to r[5]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to r[6]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to r[7]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to g[0]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to g[1]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to g[2]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to g[3]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to g[4]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to g[5]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to g[6]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to g[7]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to b[0]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to b[1]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to b[2]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to b[3]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to b[4]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to b[5]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to b[6]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to b[7]
	set_location_assignment PIN_AJ4 -to ~rst_n
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
