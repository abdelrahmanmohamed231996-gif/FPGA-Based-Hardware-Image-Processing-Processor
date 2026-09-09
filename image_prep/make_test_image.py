"""
Grab a classic test image (skimage's built-in "cameraman" photo),
shrink it to 16x16, and save it as a grayscale PNG.

Usage:
    python make_test_image.py [-o small.png] [--size 16]
"""

import argparse
from skimage import data
from PIL import Image


def make_test_image(out_path="small.png", size=16):
    img = Image.fromarray(data.camera())  # already grayscale, 512x512
    img = img.resize((size, size))
    img.save(out_path)
    print(f"Saved {size}x{size} grayscale image to {out_path}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-o", "--output", default="small.png", help="output PNG path")
    parser.add_argument("--size", type=int, default=16, help="output width/height")
    args = parser.parse_args()

    make_test_image(args.output, args.size)