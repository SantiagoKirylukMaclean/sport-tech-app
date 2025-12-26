#!/usr/bin/env python3
"""
Simple script to create a soccer ball icon using PIL
"""

try:
    from PIL import Image, ImageDraw
    import sys

    # Create a 1024x1024 image (high res for icon generation)
    size = 1024
    img = Image.new('RGBA', (size, size), (255, 255, 255, 0))
    draw = ImageDraw.Draw(img)

    # Draw white circle background
    padding = 50
    draw.ellipse([padding, padding, size-padding, size-padding],
                 fill='white', outline='black', width=15)

    # Draw black pentagons/hexagons to simulate soccer ball pattern
    center = size // 2

    # Center pentagon
    pentagon_size = 120
    points = []
    import math
    for i in range(5):
        angle = (i * 72 - 90) * math.pi / 180
        x = center + pentagon_size * math.cos(angle)
        y = center + pentagon_size * math.sin(angle)
        points.append((x, y))
    draw.polygon(points, fill='black', outline='black')

    # Add some hexagons around
    hex_positions = [
        (center, center - 250),  # top
        (center + 220, center - 120),  # top right
        (center + 220, center + 120),  # bottom right
        (center, center + 250),  # bottom
        (center - 220, center + 120),  # bottom left
        (center - 220, center - 120),  # top left
    ]

    for hx, hy in hex_positions:
        hex_size = 80
        hex_points = []
        for i in range(6):
            angle = (i * 60 - 30) * math.pi / 180
            x = hx + hex_size * math.cos(angle)
            y = hy + hex_size * math.sin(angle)
            hex_points.append((x, y))
        draw.polygon(hex_points, fill='black', outline='black')

    # Save the image
    output_path = 'assets/icons/app_icon.png'
    img.save(output_path, 'PNG')
    print(f"✓ Icon created successfully at {output_path}")

except ImportError:
    print("PIL (Pillow) not installed. Installing...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "Pillow"])
    print("Please run the script again.")
    sys.exit(1)
