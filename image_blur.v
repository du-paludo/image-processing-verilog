module image_blur(
    input clk,
    input reset,
    input start,
    input [7:0] image_in,       // Input pixel data (1 byte per clock)
    input [1:0] kernel_type,
    output reg [7:0] image_out, // Output pixel data (1 byte per clock)
    output reg done             // Done signal
);

parameter WIDTH = 350;
parameter HEIGHT = 350;
parameter KERNEL_SIZE = 3;

reg[7:0] inputImage[0 : WIDTH*HEIGHT*3-1]; // Input/output image
reg[7:0] outputImage[0 : WIDTH*HEIGHT*3-1]; // Output image
reg[7:0] kernel[0 : KERNEL_SIZE*KERNEL_SIZE-1]; // Kernel coefficients

integer row, col, color_cycle; // Row and column counters
reg[31:0] acc_R, acc_G, acc_B; // Accumulators for RGB channels
reg[31:0] divider; // Divider for normalization

// FSM states
reg[2:0] state = IDLE;
parameter IDLE = 0, LOAD_IMAGE = 1, PROCESS_PIXEL = 2, WRITE_IMAGE = 3, DONE = 4;
parameter GAUSSIAN = 0, MEAN = 1;
// Initialization
always @(posedge clk or posedge reset) begin
    if (reset) begin
        done <= 0;
        row <= 0;
        col <= 0;
        color_cycle <= 0;
        acc_R <= 0;
        acc_G <= 0;
        acc_B <= 0;
        divider <= 0;

        // Initialize kernel with chosen coefficients
        case (kernel_type)
            GAUSSIAN: begin
                kernel[0] <= 1; kernel[1] <= 2; kernel[2] <= 1;
                kernel[3] <= 2; kernel[4] <= 4; kernel[5] <= 2;
                kernel[6] <= 1; kernel[7] <= 2; kernel[8] <= 1;
            end
            MEAN: begin
                kernel[0] <= 1; kernel[1] <= 1; kernel[2] <= 1;
                kernel[3] <= 1; kernel[4] <= 1; kernel[5] <= 1;
                kernel[6] <= 1; kernel[7] <= 1; kernel[8] <= 1;
            end
        endcase
        
    end else begin
        case (state)
            IDLE: begin
                $display("Waiting for start signal\n");
                if (start) begin
                    state <= LOAD_IMAGE;
                    $display("Loading input image");
                end
            end
            LOAD_IMAGE: begin
                // Simulate loading image into memory (external interface)
                // In real design, connect image_in to external memory
                if (row < HEIGHT && col < WIDTH) begin
                    $display("Row: %2d, Col: %2d, Color cycle: %2d", row, col, color_cycle);
                    case (color_cycle)
                        0: inputImage[(row * WIDTH + col) * 3 + 0] <= image_in; // Red
                        1: inputImage[(row * WIDTH + col) * 3 + 1] <= image_in; // Green
                        2: begin
                            inputImage[(row * WIDTH + col) * 3 + 2] <= image_in; // Blue
                            col <= col + 1; // Move to the next column after Blue
                            if (col == WIDTH-1) begin
                                col <= 0;       // Reset column
                                row <= row + 1; // Move to the next row
                            end
                        end
                    endcase
                    color_cycle <= (color_cycle + 1) % 3;
                end else begin
                    // Display all input image data
                    /*for (integer i = 0; i < WIDTH*HEIGHT*3; i = i + 1) begin
                        $display("Input image[%2d]: %2X", i, inputImage[i]);
                    end*/
                    $display("Finished loading input image\n");
                    row <= 0;
                    col <= 0;
                    color_cycle <= 0;
                    state <= PROCESS_PIXEL;
                    $display("Processing image");
                end
            end
            PROCESS_PIXEL: begin
                // Apply kernel to calculate new RGB values
                // Boundary handling
                if (row < HEIGHT && col < WIDTH) begin
                    $display("Row: %2d, Col: %2d", row, col);
                    acc_R = 0;
                    acc_G = 0;
                    acc_B = 0;
                    divider = 0; // Normalization factor (sum of kernel)
                    for (integer ki = 0; ki < KERNEL_SIZE; ki++) begin
                        for (integer kj = 0; kj < KERNEL_SIZE; kj++) begin
                            if (row+ki-1 >= 0 && row+ki-1 <= HEIGHT-1 && col+kj-1 >= 0 && col+kj-1 <= WIDTH-1) begin
                                acc_R = acc_R + kernel[ki*KERNEL_SIZE+kj] * inputImage[((row+ki-1)*WIDTH + (col+kj-1))*3];
                                acc_G = acc_G + kernel[ki*KERNEL_SIZE+kj] * inputImage[((row+ki-1)*WIDTH + (col+kj-1))*3+1];
                                acc_B = acc_B + kernel[ki*KERNEL_SIZE+kj] * inputImage[((row+ki-1)*WIDTH + (col+kj-1))*3+2];
                                divider = divider + kernel[ki*KERNEL_SIZE+kj];
                            end
                        end
                    end
                    // Normalize the result
                    outputImage[(row*WIDTH + col) * 3] = acc_R / divider;
                    outputImage[(row*WIDTH + col) * 3 + 1] = acc_G / divider;
                    outputImage[(row*WIDTH + col) * 3 + 2] = acc_B / divider;

                    col <= col + 1; // Move to the next column after Blue
                    if (col == WIDTH-1) begin
                        col <= 0;       // Reset column
                        row <= row + 1; // Move to the next row
                    end
                end else begin
                    // Display all output image data
                    /*for (integer i = 0; i < WIDTH*HEIGHT*3; i = i + 1) begin
                        $display("Output image[%2d]: %2X", i, outputImage[i]);
                    end*/
                    $display("Finished processing image\n");
                    state <= WRITE_IMAGE;
                    done <= 1;
                    row <= 0;
                    col <= 0;
                    $display("Writing output image");
                end
            end
            WRITE_IMAGE: begin
                // Write back processed image
                if (row < HEIGHT && col < WIDTH) begin
                    $display("Row: %2d, Col: %2d, Color cycle: %2d", row, col, color_cycle);
                    case (color_cycle)
                        0: image_out = outputImage[(row * WIDTH + col) * 3 + 0]; // Red
                        1: image_out = outputImage[(row * WIDTH + col) * 3 + 1]; // Green
                        2: begin
                            image_out = outputImage[(row * WIDTH + col) * 3 + 2]; // Blue
                            col <= col + 1; // Move to the next column after Blue
                            if (col == WIDTH-1) begin
                                col <= 0;       // Reset column
                                row <= row + 1; // Move to the next row
                            end
                        end
                    endcase
                    color_cycle <= (color_cycle + 1) % 3;
                end else begin
                    $display("Finished writing output image\n");
                    state <= DONE;
                end
            end
            DONE: begin
                // Output is complete
            end
        endcase
    end
end

endmodule