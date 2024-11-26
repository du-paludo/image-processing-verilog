import numpy as np
from imageio.v3 import imread
import sys

imageName = sys.argv[1]

# Read the 8-bit BMP image
image = imread(imageName + '.bmp')  # Replace with the actual file path

# Get the dimensions of the image
height, width, _ = image.shape

# Initialize a list to store the RGB values
a = []

# Process the image row-by-row from the last row to the first row
for i in range(height - 1, -1, -1):  # From last row to the first row
    for j in range(width):  # Loop through each column
        a.append(image[i, j, 0])  # Red component
        a.append(image[i, j, 1])  # Green component
        a.append(image[i, j, 2])  # Blue component

# Open a file to write the hex values
with open('input.hex', 'w') as fid:
    for value in a:
        fid.write(f'{value:x}\n')  # Write each value in hexadecimal format

print("Text file write done")