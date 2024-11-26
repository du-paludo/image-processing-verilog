module read_image(
    input clk
);

parameter width = 960;
parameter height = 539;
parameter byteAmount = width * height * 3;

reg[7:0] image[0:byteAmount-1];

integer old_R[0:height-1][0:width-1];
integer old_G[0:height-1][0:width-1];
integer old_B[0:height-1][0:width-1];

integer new_R[0:height-1][0:width-1];
integer new_G[0:height-1][0:width-1];
integer new_B[0:height-1][0:width-1];

integer kernel[0:2][0:2];

integer divider, ni, nj;

initial begin
    kernel[0][0] = 1;
    kernel[0][1] = 2;
    kernel[0][2] = 1;
    kernel[1][0] = 2;
    kernel[1][1] = 4;
    kernel[1][2] = 2;
    kernel[2][0] = 1;
    kernel[2][1] = 2;
    kernel[2][2] = 1;

    // Read bytes from image.hex file
    $readmemh("input.hex", image, 0, byteAmount-1);

    for (integer i = 0; i < height; i++) begin
        for (integer j = 0; j < width; j++) begin
            old_R[i][j] = image[(i*width + j) * 3];
            old_G[i][j] = image[(i*width + j) * 3 + 1];
            old_B[i][j] = image[(i*width + j) * 3 + 2];

            new_R[i][j] = 0;
            new_G[i][j] = 0;
            new_B[i][j] = 0;
        end
    end

    for (integer i = 0; i < height; i++) begin
        for (integer j = 0; j < width; j++) begin
            divider = 0;
            for (integer ki = 0; ki < 3; ki++) begin
                for (integer kj = 0; kj < 3; kj++) begin
                    // Calculate the indices of the neighboring pixel
                    ni = i + ki - 1; // Neighbor row index
                    nj = j + kj - 1; // Neighbor column index

                    // Check if neighbor indices are within bounds
                    if (ni >= 0 && ni < height && nj >= 0 && nj < width) begin
                        new_R[i][j] = new_R[i][j] + kernel[ki][kj] * old_R[ni][nj];
                        new_G[i][j] = new_G[i][j] + kernel[ki][kj] * old_G[ni][nj];
                        new_B[i][j] = new_B[i][j] + kernel[ki][kj] * old_B[ni][nj];
                        divider = divider + kernel[ki][kj];
                    end
                end
            end
            //$display("R: %d, G: %d, B: %d", new_R[i][j], new_G[i][j], new_B[i][j]);
            new_R[i][j] = new_R[i][j] / divider;
            new_G[i][j] = new_G[i][j] / divider;;
            new_B[i][j] = new_B[i][j] / divider;
        end
    end

    // for (integer i = 0; i < height; i++) begin
    //     for (integer j = 0; j < width; j++) begin
    //         $display("R: %d, G: %d, B: %d", new_R[i][j], new_G[i][j], new_B[i][j]);
    //     end
    // end

    for (integer i = 0; i < height; i++) begin
        for (integer j = 0; j < width; j++) begin
            image[(i*width + j) * 3] = new_R[i][j];
            image[(i*width + j) * 3 + 1] = new_G[i][j];
            image[(i*width + j) * 3 + 2] = new_B[i][j];
        end
    end

    // Write bytes to output.hex file
    $writememh("output.hex", image, 0, byteAmount-1);
end

endmodule