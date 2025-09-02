`timescale 1ns / 1ps
module register (
    input clk,
    input rst,
    input [31:0] data_in,
    output [31:0] data_out
    );

    reg [31:0] data_reg;

    assign data_out = data_reg;

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            data_reg <= 0;
        end else begin
            data_reg <= data_in;
        end
    end
 
endmodule
