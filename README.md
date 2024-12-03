# Image Processor in Verilog

This project implements an image processing pipeline in Verilog. It is designed to load, process, and save images represented in a hexadecimal format. The system supports basic operations such as convolution filtering with a kernel for image processing.

## Features

- **Load Image:** Reads an input image in hexadecimal format using an 8-bit interface.

- **Process Image:** Applies a convolution kernel to the input image.

- **Save Image:** Outputs the processed image in hexadecimal format.

- **Generic Handling of Borders:** Processes all pixels, including image borders, with boundary checks.

## Requirements

- Verilog Simulator (e.g., ModelSim, Vivado, etc.)

- Input image in hexadecimal format (input.hex)

- Output storage for the processed image (output.hex)

- Python 3.11 and NumPy and ImageIo libraries for image conversion

## Files

- `image_blur.v`: module for the image loading, processing, and saving.
  
- `image_blur_TB.v`: testbench for the image_blur module.
  
- `input.hex`: input image in hexadecimal format.
  
- `output.hex`: modified image in hexadecimal format.
  
- `convert-bmp-hex.py`: Python script to convert a BMP image to hexadecimal format.
  
- `convert-hex-bmp.py`: Python script to convert a hexadecimal image to BMP format.
  
- `script.sh`: Bash script to automate the conversion process.
  
- `README.md`: project description and instructions.

## Usage

1. Change the WIDTH and HEIGHT parameters in the `image_blur.v`, `image_blur_TB.v` and `convert-hex-bmp.py` files to match the input image dimensions.

2. Convert the input image to hexadecimal format using the `convert-bmp-hex.py` script.

```bash
python convert-bmp-hex.py input.bmp
```

3. Run the Verilog simulation using the testbench file.

```bash
iverilog -o image_blur image_blur_TB.v image_blur.v
./image_blur
```

4. Remove extra lines from output and convert the output image from hexadecimal to BMP format using the `convert-hex-bmp.py` script.

```bash
grep -v // output.hex > formatted_output.hex
python convert-hex-bmp.py output.hex
```

5. View the processed image in the BMP format.

Alternatively, just run the `script.sh` file to automate the conversion process.

```bash
./script.sh
```

## Implementation Details

### State Machine for Image Loading

- States:

    - **LOAD_IMAGE:** Sequentially loads the R, G, and B channels for each pixel using an 8-bit image_in interface.

    - **PROCESS_PIXEL:** Applies the convolution kernel to each pixel.

    - **SAVE_IMAGE:** Writes the processed pixel data to the output hex file.

### Convolution Kernel

- Example Kernel:

```
1  2  1
2  4  2
1  2  1
```

- Handles image borders by checking bounds for each neighboring pixel.

### Synchronization

- Utilizes non-blocking assignments (<=) for sequential logic to ensure proper timing in the simulation and synthesizability.

## Customization

- Modify the WIDTH and HEIGHT parameters in the Verilog code to adjust the resolution.

- Update the convolution kernel values for different filters.

- Adjust the interface to connect with external memory or peripherals as needed.

## Known Limitations

- Memory size is determined by the WIDTH and HEIGHT parameters and may need adjustment for large images.
