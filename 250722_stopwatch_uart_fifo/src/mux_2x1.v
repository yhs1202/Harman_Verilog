`timescale 1ns / 1ps

module mux_2x1 #(
    parameter   WIDTH = 4
) (
    input                   sel,
    input       [WIDTH-1:0] first,
    input       [WIDTH-1:0] second,
    output reg  [WIDTH-1:0] o_data
);

    always @(*) begin
        case(sel)
            1'b0: o_data = first;
            1'b1: o_data = second;
            default: o_data = first;
        endcase
    end

endmodule
