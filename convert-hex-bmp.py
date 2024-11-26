import numpy as np
from imageio import imwrite
import sys

# Parameters (adjust as needed)
width = 960  # Width of the original BMP image
height = 539  # Height of the original BMP image
hex_file = 'formatted_output.hex'  # Input hex file
output_bmp = 'output.bmp'  # Output BMP file

# Read the hexadecimal file
with open(hex_file, 'r') as f:
    hex_values = f.read().splitlines()

# Convert hex values to integers
pixels = [int(value, 16) for value in hex_values]

# Reshape the data to match the image dimensions and RGB channels
# Each pixel has 3 values (R, G, B)
image_array = np.zeros((height, width, 3), dtype=np.uint8)

k = 0
for i in range(height - 1, -1, -1):  # BMP rows are stored bottom-to-top
    for j in range(width):
        image_array[i, j, 0] = pixels[k]     # Red
        image_array[i, j, 1] = pixels[k + 1]  # Green
        image_array[i, j, 2] = pixels[k + 2]  # Blue
        k += 3

# Write the image array to a BMP file
imwrite(output_bmp, image_array)
print(f"Image successfully written to {output_bmp}")