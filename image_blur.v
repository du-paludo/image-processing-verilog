module image_blur(
    input clk,
    input reset,
    input start,
    input [7:0] image_in,       // Input pixel data (1 byte per clock)
    output reg [7:0] image_out, // Output pixel data (1 byte per clock)
    output reg done             // Done signal
);

parameter WIDTH = 20;
parameter HEIGHT = 20;
parameter KERNEL_SIZE = 3;

reg[7:0] image[0 : WIDTH*HEIGHT*3-1]; // Input/output image
reg[7:0] kernel[0 : KERNEL_SIZE*KERNEL_SIZE-1]; // Kernel coefficients

reg[15:0] row, col; // Row and column counters
reg[31:0] acc_R, acc_G, acc_B; // Accumulators for RGB channels
reg[31:0] divider; // Divider for normalization

// FSM states
typedef enum reg[2:0] {
    IDLE,
    LOAD_IMAGE,
    PROCESS_PIXEL,
    WRITE_IMAGE,
    DONE
} state_t;
state_t state;

// Initialization
always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        done <= 0;
        row <= 0;
        col <= 0;
        acc_R <= 0;
        acc_G <= 0;
        acc_B <= 0;
        divider <= 0;

        // Initialize kernel with gaussian blur coefficients
        kernel[0] <= 1; kernel[1] <= 2; kernel[2] <= 1;
        kernel[3] <= 2; kernel[4] <= 4; kernel[5] <= 2;
        kernel[6] <= 1; kernel[7] <= 2; kernel[8] <= 1;
    end else begin
        case (state)
            IDLE: begin
                if (start) state <= LOAD_IMAGE;
            end
            LOAD_IMAGE: begin
                // Simulate loading image into memory (external interface)
                // In real design, connect image_in to external memory
                if (row < HEIGHT && col < WIDTH) begin
                    image[row * WIDTH + col] <= image_in;
                    col <= col + 1;
                    if (col == WIDTH-1) begin
                        col <= 0;
                        row <= row + 1;
                    end
                end else begin
                    row <= 0;
                    col <= 0;
                    state <= PROCESS_PIXEL;
                end
            end
            PROCESS_PIXEL: begin
                // Apply kernel to calculate new RGB values
                // Boundary handling
                if (row > 0 && row < HEIGHT-1 && col > 0 && col < WIDTH-1) begin
                    acc_R <= 0;
                    acc_G <= 0;
                    acc_B <= 0;
                    divider <= 16; // Normalization factor (sum of kernel)
                    for (integer ki = 0; ki < KERNEL_SIZE; ki++) begin
                        for (integer kj = 0; kj < KERNEL_SIZE; kj++) begin
                            acc_R <= acc_R + kernel[ki*KERNEL_SIZE+kj] * image[((row+ki-1)*WIDTH + (col+kj-1))*3];
                            acc_G <= acc_G + kernel[ki*KERNEL_SIZE+kj] * image[((row+ki-1)*WIDTH + (col+kj-1))*3+1];
                            acc_B <= acc_B + kernel[ki*KERNEL_SIZE+kj] * image[((row+ki-1)*WIDTH + (col+kj-1))*3+2];
                        end
                    end
                end
                // Move to the next pixel
                col <= col + 1;
                if (col == WIDTH-1) begin
                    col <= 0;
                    row <= row + 1;
                    if (row == HEIGHT-1) state <= WRITE_IMAGE;
                end
            end
            WRITE_IMAGE: begin
                // Write back processed image
                image_out <= image[row*WIDTH + col];
                col <= col + 1;
                if (col == WIDTH-1) begin
                    col <= 0;
                    row <= row + 1;
                    if (row == HEIGHT-1) begin
                        state <= DONE;
                        done <= 1;
                    end
                end
            end
            DONE: begin
                // Output is complete
            end
        endcase
    end
end

endmodule