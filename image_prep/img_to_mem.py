"""
Convert a 16x16 grayscale image into image.mem (one 2-digit hex byte
per line, row-major order: row0col0, row0col1, ..., row15col15),
matching the format $readmemh expects in image_bram.v.

Usage:
    python img_to_mem.py input.png -o image.mem
"""

import argparse
from PIL import Image


def convert(in_path, out_path, size=16):
    img = Image.open(in_path).convert("L")          # force grayscale
    if img.size != (size, size):
        img = img.resize((size, size))               # force 16x16

    pixels = list(img.getdata())                      # row-major, 0..255

    with open(out_path, "w") as f:
        for p in pixels:
            f.write(f"{p:02x}\n")

    print(f"Wrote {len(pixels)} bytes to {out_path}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("input", help="input image path")
    parser.add_argument("-o", "--output", default="image.mem", help="output .mem path")
    parser.add_argument("--size", type=int, default=16, help="image width/height (default 16)")
    args = parser.parse_args()

    convert(args.input, args.output, args.size)