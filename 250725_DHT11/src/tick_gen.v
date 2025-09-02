`timescale 1ns / 1ps

module tick_gen(
    input clk_in, rst,
    output reg tick_1Mhz
);
    parameter DIV = 100; // 100 MHz clock to 1MHz tick (1 us period)
    localparam WIDTH = $clog2(DIV); 
    reg [WIDTH-1:0] r_count;

    always @(posedge clk_in, posedge rst) begin
        if (rst) begin
            r_count <= 0;
            tick_1Mhz <= 1'b0;
        end else if (r_count == DIV - 1) begin
            r_count <= 0;
            tick_1Mhz <= 1'b1;
        end else begin
            r_count <= r_count + 1;
            tick_1Mhz <= 1'b0;
        end
    end
endmodule