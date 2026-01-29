#!/usr/bin/env python3
"""
Generate PNG icons from the icon.svg pixel data.
Creates multiple sizes for different platforms.
"""

import struct
import zlib
import os
import re

# Parse the SVG to extract pixel colors
def parse_svg_pixels(svg_path):
    """Parse SVG and extract 16x16 pixel colors."""
    with open(svg_path, 'r') as f:
        svg_content = f.read()

    # Initialize 16x16 transparent grid
    pixels = [[(0, 0, 0, 0) for _ in range(16)] for _ in range(16)]

    # Parse rect elements: <rect x="2" y="0" width="1" height="1" fill="#3C2415"/>
    pattern = r'<rect x="(\d+)" y="(\d+)" width="1" height="1" fill="(#[A-Fa-f0-9]{6})"/>'

    for match in re.finditer(pattern, svg_content):
        x = int(match.group(1))
        y = int(match.group(2))
        color_hex = match.group(3)

        # Parse hex color
        r = int(color_hex[1:3], 16)
        g = int(color_hex[3:5], 16)
        b = int(color_hex[5:7], 16)

        if 0 <= x < 16 and 0 <= y < 16:
            pixels[y][x] = (r, g, b, 255)

    return pixels

def scale_pixels(pixels, scale):
    """Scale pixel array by integer factor using nearest neighbor."""
    original_size = len(pixels)
    new_size = original_size * scale
    scaled = []

    for y in range(new_size):
        row = []
        for x in range(new_size):
            orig_x = x // scale
            orig_y = y // scale
            row.append(pixels[orig_y][orig_x])
        scaled.append(row)

    return scaled

def create_png(pixels, output_path):
    """Create a PNG file from pixel data without external libraries."""
    height = len(pixels)
    width = len(pixels[0]) if height > 0 else 0

    def png_chunk(chunk_type, data):
        chunk_len = struct.pack('>I', len(data))
        chunk_crc = struct.pack('>I', zlib.crc32(chunk_type + data) & 0xffffffff)
        return chunk_len + chunk_type + data + chunk_crc

    # PNG signature
    signature = b'\x89PNG\r\n\x1a\n'

    # IHDR chunk
    ihdr_data = struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0)
    ihdr = png_chunk(b'IHDR', ihdr_data)

    # IDAT chunk (image data)
    raw_data = b''
    for row in pixels:
        raw_data += b'\x00'  # Filter type: None
        for r, g, b, a in row:
            raw_data += bytes([r, g, b, a])

    compressed = zlib.compress(raw_data, 9)
    idat = png_chunk(b'IDAT', compressed)

    # IEND chunk
    iend = png_chunk(b'IEND', b'')

    # Write PNG file
    with open(output_path, 'wb') as f:
        f.write(signature + ihdr + idat + iend)

    print(f"Created: {output_path} ({width}x{height})")

def create_ico(png_sizes, output_path):
    """Create a Windows .ico file from multiple PNG sizes."""
    # ICO header
    header = struct.pack('<HHH', 0, 1, len(png_sizes))  # Reserved, Type (1=ICO), Count

    entries = []
    image_data = []
    offset = 6 + len(png_sizes) * 16  # Header + entries

    for png_path, size in png_sizes:
        with open(png_path, 'rb') as f:
            png_data = f.read()

        # ICO directory entry
        entry = struct.pack('<BBBBHHII',
            size if size < 256 else 0,  # Width (0 = 256)
            size if size < 256 else 0,  # Height (0 = 256)
            0,                           # Color palette
            0,                           # Reserved
            1,                           # Color planes
            32,                          # Bits per pixel
            len(png_data),               # Size of image data
            offset                       # Offset to image data
        )
        entries.append(entry)
        image_data.append(png_data)
        offset += len(png_data)

    with open(output_path, 'wb') as f:
        f.write(header)
        for entry in entries:
            f.write(entry)
        for data in image_data:
            f.write(data)

    print(f"Created: {output_path}")

def main():
    # Paths
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(os.path.dirname(script_dir))
    svg_path = os.path.join(project_root, 'assets', 'ui', 'icon.svg')
    assets_dir = os.path.join(project_root, 'assets')

    # Create icons directory
    icons_dir = os.path.join(assets_dir, 'icons')
    os.makedirs(icons_dir, exist_ok=True)

    print(f"Parsing: {svg_path}")
    pixels = parse_svg_pixels(svg_path)

    # Generate PNGs at various sizes
    sizes = [16, 32, 48, 64, 128, 256, 512]
    png_files = []

    for size in sizes:
        scale = size // 16
        scaled_pixels = scale_pixels(pixels, scale)
        output_path = os.path.join(icons_dir, f'icon_{size}.png')
        create_png(scaled_pixels, output_path)
        png_files.append((output_path, size))

    # Create main icon.png (256x256 for Godot)
    main_icon_path = os.path.join(assets_dir, 'icon.png')
    scale = 256 // 16
    scaled_pixels = scale_pixels(pixels, scale)
    create_png(scaled_pixels, main_icon_path)

    # Create favicon.png (32x32 for web)
    favicon_path = os.path.join(project_root, 'favicon.png')
    scale = 32 // 16
    scaled_pixels = scale_pixels(pixels, scale)
    create_png(scaled_pixels, favicon_path)

    # Create Windows .ico file (multiple sizes)
    ico_sizes = [(p, s) for p, s in png_files if s in [16, 32, 48, 256]]
    ico_path = os.path.join(assets_dir, 'icon.ico')
    create_ico(ico_sizes, ico_path)

    print("\nDone! Created icons:")
    print(f"  - {main_icon_path} (Godot project icon)")
    print(f"  - {favicon_path} (Web favicon)")
    print(f"  - {ico_path} (Windows icon)")
    print(f"  - {icons_dir}/ (All sizes)")

if __name__ == '__main__':
    main()
