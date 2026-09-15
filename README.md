# MATLAB Golden Model - 2D Convolution FPGA

Run `golden_model_main.m`.

Baseline from the project specification:
- 16x16 grayscale input
- 8-bit unsigned pixels
- 3x3 window
- 3x3 signed kernel
- stride 1
- VALID/no padding
- kernel is not spatially flipped
- output = 14x14

## What goes to the FPGA?

The MATLAB output is generated as a file; MATLAB itself is NOT synthesized.

`input_image.mem`
- input pixels for the FPGA convolution RTL.

`kernel_rom.mem`
- all pre-stored 3x3 filters.
- FPGA switches/software select one filter.
- This replaces the old example signals `kernel_load`, `kernel_addr`, `kernel_data`.

`golden_output_raw.mem`
- MATLAB expected MAC result, signed two's-complement.
- Put this into a Golden/Reference ROM or BRAM if you want the FPGA to compare RTL output against MATLAB internally.

`golden_output_display.mem`
- 8-bit saturated result for Frame Buffer/VGA display tests.

## FPGA verification

MATLAB:
    input_image.mem + kernel_rom.mem + golden_output_raw.mem

FPGA:
    Input BRAM -> 3x3 line buffer/window -> selected kernel -> MAC -> RTL output
                                                              |
                                                              v
                                                        Comparator
                                                              ^
                                                              |
                                                     Golden BRAM

If comparison is on FPGA:
- RTL output = ACTUAL
- golden_output_raw.mem = EXPECTED

If display is also needed:
- RTL output -> Output Writer -> Frame Buffer -> VGA -> Monitor

The project documents recommend the preloaded `.mem`/test-vector method as the core input method and define MATLAB as an independent golden reference.
