# MATLAB Golden Model — 2D Convolution FPGA

This folder contains the complete MATLAB reference model used to validate the
RTL convolution pipeline before and after synthesis. All `.m` files and the
test input image live here so the model can be run standalone, independent
of the FPGA toolchain.

## Files

| File | Role |
|---|---|
| `golden_model_main.m` | Entry point. Loads the image, runs the convolution, writes all `.mem`/`.txt` test vectors, and (optionally) compares against an RTL output file. Self-contained — also carries local copies of the helper functions below so it can run on its own. |
| `conv2d_golden.m` | Standalone 3x3 VALID convolution function (`raw`, `display` outputs), used when driving the model from other scripts. |
| `get_kernel_bank.m` | Defines the fixed bank of 3x3 filters (identity, edge_h, edge_v, sharpen, blur, custom_edge, ...). |
| `read_rtl_mem.m` | Parses an RTL output file (decimal or hex) into signed values, for comparison against the golden output. |
| `write_hex_mem.m` | Writes unsigned values as hex, one per line. |
| `write_signed_hex_mem.m` | Writes signed values as two's-complement hex, one per line. |
| `write_decimal_mem.m` | Writes signed decimal values, one per line. |
| `write_kernel_bank_mem.m` | Writes every filter in the bank consecutively (9 coefficients each) as a kernel ROM image. |
| `input_image.png` | 16x16 test image used as the model's input. |

## How to run

1. Open MATLAB (or Octave) in this folder.
2. Run:
   ```matlab
   golden_model_main
   ```
3. The script:
   - Loads `input_image.png` and converts it to 16x16 8-bit grayscale.
   - Selects one filter from the kernel bank (`FILTER_SELECT` inside the script).
   - Runs the golden 3x3 VALID convolution (stride 1, no padding, kernel not spatially flipped).
   - Displays the input and output images.
   - Writes all test vectors into a generated `FPGA_TEST_VECTORS/` folder.

## Model parameters (baseline)

- Input: 16x16 grayscale, 8-bit unsigned pixels
- Kernel: 3x3, signed
- Stride: 1, padding: VALID (no padding)
- Output: 14x14
- Accumulator: 20-bit signed

## Generated test vectors (`FPGA_TEST_VECTORS/`)

| File | Description |
|---|---|
| `input_image.mem` | Input pixels for the FPGA convolution RTL. |
| `kernel_selected.mem` | The single filter currently selected by `FILTER_SELECT`. |
| `kernel_rom.mem` | All pre-stored 3x3 filters, back to back — this is what the FPGA kernel ROM/registers are preloaded with. |
| `golden_output_raw.mem` | MATLAB's expected MAC result, signed two's-complement — the golden reference for RTL comparison. |
| `golden_output_display.mem` | 8-bit saturated result, for Frame Buffer/VGA display tests. |
| `golden_output_raw_decimal.txt` | Same as the raw output, but in decimal for easy human inspection. |
| `test_config.txt` | Snapshot of every parameter used for the run (image size, kernel size, stride, padding, output size, accumulator width, selected filter). |
| `filter_list.txt` | Index-to-name mapping for every filter in the bank. |

## Verifying against RTL

Drop the simulator's output (e.g. from ModelSim) into
`FPGA_TEST_VECTORS/rtl_output.mem`, then re-run `golden_model_main`. If the
file is present, the script automatically compares it against
`golden_output_raw.mem` element by element and reports PASS/FAIL plus the
first mismatches (index, row, column, golden vs. RTL value).

```
MATLAB:  input_image.mem + kernel_rom.mem + golden_output_raw.mem
                                │
FPGA:    Input BRAM → 3x3 line buffer/window → selected kernel → MAC → RTL output
                                                                     │
                                                                     ▼
                                                              Comparator
                                                                     ▲
                                                                     │
                                                              Golden BRAM
```

If display is also needed: `RTL output → Output Writer → Frame Buffer → VGA → Monitor`.

The preloaded `.mem` / test-vector method is the project's primary
verification path; MATLAB is treated as an independent golden reference and
is never synthesized.
