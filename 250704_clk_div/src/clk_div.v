`timescale 1ns / 1ps
module clk_div #(
    parameter DIV = 10
) (
    input clk_in,
    input reset,
    output reg clk_out
);
    localparam WIDTH = $clog2(DIV);
    reg [WIDTH-1:0] r_count;

    always @(posedge clk_in, posedge reset) begin
        if (reset) begin
            r_count <= 0;
            clk_out <= 1'b0;
        end else begin

            if (r_count == DIV - 1) begin
                r_count <= 0;
            end else r_count <= r_count + 1;
        end
        
        if (r_count == (DIV / 2) - 1) begin
            clk_out <= 1'b1;
        end else if (r_count == DIV - 1) begin
            clk_out <= 1'b0;
        end
    end
endmodule
