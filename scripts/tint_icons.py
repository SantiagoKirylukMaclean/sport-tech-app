#!/usr/bin/env python3
"""
Script to tint Android launcher icons with a color overlay for stage builds.
This helps distinguish between stage and production apps.
"""
from PIL import Image, ImageEnhance
import sys
import os

def tint_icon(input_path, output_path, tint_color=(255, 140, 0)):
    """
    Apply a color tint to an icon image.

    Args:
        input_path: Path to the input icon
        output_path: Path to save the tinted icon
        tint_color: RGB tuple for the tint color (default: orange)
    """
    # Open the image
    img = Image.open(input_path).convert('RGBA')

    # Create a tinted version
    # First, reduce saturation a bit to make the tint more visible
    enhancer = ImageEnhance.Color(img)
    img = enhancer.enhance(0.7)

    # Create an overlay with the tint color
    overlay = Image.new('RGBA', img.size, tint_color + (100,))

    # Blend the overlay with the original image
    tinted = Image.alpha_composite(img, overlay)

    # Save the result
    tinted.save(output_path, 'PNG')
    print(f"Created tinted icon: {output_path}")

def main():
    # Base directories
    main_res = "/Users/santiago/workspace/sport-tech-app/android/app/src/main/res"
    stage_res = "/Users/santiago/workspace/sport-tech-app/android/app/src/stage/res"
    prod_res = "/Users/santiago/workspace/sport-tech-app/android/app/src/prod/res"

    # Icon densities
    densities = ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']

    # Orange tint for stage (RGB)
    stage_tint = (255, 140, 0)  # Orange

    print("Generating stage icons with orange tint...")
    for density in densities:
        input_file = f"{main_res}/mipmap-{density}/ic_launcher.png"
        output_file = f"{stage_res}/mipmap-{density}/ic_launcher.png"

        if os.path.exists(input_file):
            tint_icon(input_file, output_file, stage_tint)
        else:
            print(f"Warning: {input_file} not found")

    print("\nCopying original icons to prod...")
    for density in densities:
        input_file = f"{main_res}/mipmap-{density}/ic_launcher.png"
        output_file = f"{prod_res}/mipmap-{density}/ic_launcher.png"

        if os.path.exists(input_file):
            img = Image.open(input_file)
            img.save(output_file, 'PNG')
            print(f"Copied: {output_file}")
        else:
            print(f"Warning: {input_file} not found")

    print("\nDone! Icons generated for both stage and prod flavors.")

if __name__ == "__main__":
    main()
