`timescale 1ns/1ps

module image_blur_TB();

parameter WIDTH = 20;
parameter HEIGHT = 12;

reg clk = 1'b0;
reg reset = 1'b1;
reg start = 1'b0;
reg [7:0] image_in = 1'b0;
wire [7:0] image_out;
wire done;

reg [7:0] image_memory [0:WIDTH*HEIGHT*3-1];
integer i;

integer out_file;

image_blur DUT(.clk(clk), .reset(reset), .start(start), .image_in(image_in), .image_out(image_out), .done(done));

always    
    #10 clk = ~clk;

initial begin
    $dumpfile("image_blur.vcd");
    $dumpvars(0, image_blur_TB);

    $readmemh("input.hex", image_memory);
    
    #20
    reset = 0;
    start = 1;

    for (i = 0; i < WIDTH * HEIGHT * 3; i = i + 1) begin
        @(posedge clk);
        image_in <= image_memory[i];
    end

    // $display("Done\n");

    wait(done)
    @(posedge clk);

    // $display("Writing output to output.hex\n");

    out_file = $fopen("output.hex", "w");
    for (i = 0; i < WIDTH * HEIGHT * 3; i = i + 1) begin
        @(posedge clk);
        $fwrite(out_file, "%02X\n", image_out);
    end
    $fclose(out_file);

    $finish();
end

endmodule