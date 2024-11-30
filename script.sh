#!/bin/bash

name="teste20x12"

python3.11 convert-bmp-hex.py $name
iverilog image_blur_TB.v image_blur.v
./a.out
grep -v // output.hex > formatted_output.hex
python3.11 convert-hex-bmp.py