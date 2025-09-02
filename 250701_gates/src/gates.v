`timescale 1ns / 1ps

module gates(
    input a, b,
    output y0, y1, y2, y3, y4, y5, y6
    );

    assign y0 = a & b;
    assign y1 = a | b;
    assign y2 = ~(a & b);
    assign y3 = ~(a | b);
    assign y4 = a ^ b;
    assign y5 = ~(a ^ b);
    assign y6 = ~b;


endmodule
