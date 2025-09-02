`timescale 1ns / 1ps

module digit_spliter #(
    parameter DS_WIDTH = 7
) (
    input  [DS_WIDTH - 1:0] i_data,
    input                   adjust_digit_sel,
    input                   on_off,
    output [3:0]            digit_1,
    output [3:0]            digit_10
);

    assign digit_1    = (on_off == 1'b0 && adjust_digit_sel == 1'b1) ? 4'hE : (i_data % 10);
    assign digit_10   = (on_off == 1'b0 && adjust_digit_sel == 1'b1) ? 4'hE : ((i_data / 10) % 10);

endmodule
