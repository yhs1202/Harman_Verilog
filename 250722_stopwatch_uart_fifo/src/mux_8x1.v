`timescale 1ns / 1ps

module mux_8x1(
    input       [2:0] sel,
    input       [3:0] digit_1,
    input       [3:0] digit_10,
    input       [3:0] digit_100,
    input       [3:0] digit_1000,
    input       [3:0] digit_off_1,
    input       [3:0] digit_off_10,
    input       [3:0] digit_dot,
    input       [3:0] digit_off_1000,
    output reg  [3:0] bcd_data
);

    always @(*) begin
        case(sel)
            3'b000: bcd_data = digit_1;
            3'b001: bcd_data = digit_10;
            3'b010: bcd_data = digit_100;
            3'b011: bcd_data = digit_1000;
            3'b100: bcd_data = digit_off_1;
            3'b101: bcd_data = digit_off_10;
            3'b110: bcd_data = digit_dot;
            3'b111: bcd_data = digit_off_1000;
            default: bcd_data = digit_1;
        endcase
    end

endmodule
