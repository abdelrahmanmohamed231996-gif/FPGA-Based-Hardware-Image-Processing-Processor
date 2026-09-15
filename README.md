# FPGA-Based Hardware Image Processing Processor

A real-time 3x3 convolution image processing pipeline implemented in Verilog
and targeted at an Altera/Intel Cyclone V FPGA (Quartus project included),
with a VGA output stage and a MATLAB golden model used to generate and
verify test vectors.

The design streams a stored grayscale image through a hardware 3x3
convolution engine (line buffers → sliding window → selectable kernel →
MAC array → adder tree), and can display the filtered result live over VGA.

## Pipeline overview

```
Input image (BRAM) ─▶ Line buffers (3x3 window) ─▶ Window generator
                                                          │
                                     Kernel select ──▶ MAC array ──▶ Adder tree
                                                          │
                                                   Output assembly
                                                          │
                                      ┌───────────────────┴───────────────────┐
                                      ▼                                       ▼
                               Frame buffer ──▶ VGA controller          RTL vs. Golden
                                                                          comparator
                                                                        (MATLAB model)
```

- **Input**: 16x16 grayscale image, 8-bit unsigned pixels
- **Kernel**: 3x3 signed, selectable from a pre-stored filter bank
- **Convolution**: stride 1, VALID (no padding), kernel not spatially flipped
- **Output**: 14x14 result, 21-bit signed accumulator, saturated to 8-bit for display

## Repository structure

| Path | Contents |
|---|---|
| `rtl/` | Synthesizable Verilog: `system_top.v` (top level), convolution datapath (`conv_top.v`, `window_gen.v`, `mac_mult_array.v`, `adder_tree.v`, `kernel_regs.v`, `addr_gen.v`, `in9_reg.v`), signed arithmetic primitives, `frame_buffer.v`, `image_bram.v`, `output_assembly.v` / `output_if.v`, and `vga_controller.v`. |
| `tb/` | Per-module testbenches (line buffer, window generator, kernel registers, adder tree, MAC array, output assembly/interface, VGA controller, full `system_top`). |
| `sim/` | ModelSim `.do` scripts to compile and run the full `system_top` simulation. |
| `scripts/` | ModelSim `.do` scripts for standalone unit-level simulations (MAC array, adder tree). |
| `modeling/` | MATLAB golden model: reference convolution, kernel bank, `.mem` test-vector generation, and RTL-vs-golden comparison. See [`modeling/README.md`](modeling/README.md). |
| `mem_files/` | Pre-generated `.mem` images: input image, kernel filters (`emboss`, `outline`, `bottom_sobel`, `identify`), and a sample dual-port RAM init file. |
| `image_prep/` | Python helpers (`make_test_image.py`, `img_to_mem.py`) to generate/convert a test image into a `.mem` file, plus a sample image. |
| `Quartus/` | Quartus II project (`2d_conv.qpf`/`.qsf`), pin assignment scripts, and synthesis/fitter output (`output_files/`). Top-level entity: `system_top`. |
| `pll/` | Generated PLL IP core (Quartus megafunction) used for clocking. |
| `docs/` | Project documentation (work in progress). |
| `synth/` | Synthesis-related notes/artifacts (work in progress). |

## Getting started

### 1. Verify with the MATLAB golden model

```matlab
cd modeling
golden_model_main
```

This generates the reference test vectors (input image, kernel ROM, golden
output, in both hex and decimal) under `modeling/FPGA_TEST_VECTORS/`. See
[`modeling/README.md`](modeling/README.md) for the full I/O description and
how to feed back an RTL simulation output for automatic PASS/FAIL comparison.

### 2. Simulate the RTL

```tcl
# from a ModelSim console, inside sim/
do sys_top.do
```

Or run the individual unit-level testbenches in `tb/` using the matching
scripts in `scripts/`.

### 3. Synthesize for hardware

Open `Quartus/2d_conv.qpf` in Quartus II/Prime. Top-level entity is
`system_top`; pin assignments for the target board are in
`Quartus/pin_assignments_system_top.tcl`.

## Verification flow

The MATLAB model is the source of truth for expected results. RTL output
(from simulation or from hardware capture) is compared against
`golden_output_raw.mem` element by element; mismatches are reported with
index, row, column, and both values. MATLAB itself is never synthesized —
only the `.mem` files it produces are loaded onto the FPGA.

## Status

Active graduation project — RTL pipeline and MATLAB golden model are
functional; VGA display integration and board-level testing are ongoing.
