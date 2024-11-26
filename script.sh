#!/bin/bash

name="tigre"

python3 convert-bmp-hex.py $name
iverilog read_image.v
./a.out
grep -v // output.hex > formatted_output.hex
python3 convert-hex-bmp.py