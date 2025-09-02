`timescale 1ns / 1ps

module half_adder (
    input  a,
    input  b,
    output s,
    output c
);

    assign s = a ^ b;
    assign c = a & b;

endmodule

module full_adder (
    input  a,
    input  b,
    input  c_in,
    output sum,   // full adder sum
    output c_out  // full adder carry out
);

    wire s1, c1, c2;

    half_adder U_HA1 (
        .a(a),
        .b(b),
        .s(s1),
        .c(c1)
    );

    half_adder U_HA2 (
        .a(s1),
        .b(c_in),
        .s(sum),
        .c(c2)
    );

    assign c_out = c1 | c2;

endmodule


module full_adder4 (
    input [3:0] a,
    input [3:0] b,
    input c_in,
    output [3:0] sum,
    output c_out

);
    wire w_c0, w_c1, w_c2;  // wire carry 0
    full_adder FA0 (
        .a(a[0]),
        .b(b[0]),
        .c_in(c_in),
        .sum(sum[0]),
        .c_out(w_c0)
    );
    full_adder FA1 (
        .a(a[1]),
        .b(b[1]),
        .c_in(w_c0),
        .sum(sum[1]),
        .c_out(w_c1)
    );
    full_adder FA2 (
        .a(a[2]),
        .b(b[2]),
        .c_in(w_c1),
        .sum(sum[2]),
        .c_out(w_c2)
    );
    full_adder FA3 (
        .a(a[3]),
        .b(b[3]),
        .c_in(w_c2),
        .sum(sum[3]),
        .c_out(c_out)
    );

endmodule

module full_adder8 (
    input [7:0] a,
    input [7:0] b,
    // input c_in,
    output [7:0] sum,
    output c_out,

    output [7:0] fnd_data,
    output [3:0] fnd_com
);

    wire w;
    fnd_controller U_FND (
        .sum(),
        .fnd_data()
    );


    full_adder4 FA4_0 (
        .a(a[3:0]),
        .b(b[3:0]),
        .c_in(1'b0),
        .sum(sum[3:0]),
        .c_out(w)
    );
    full_adder4 FA4_1 (
        .a(a[7:4]),
        .b(b[7:4]),
        .c_in(w),
        .sum(sum[7:4]),
        .c_out(c_out)
    );
endmodule

module calculator (
    input  [7:0] a,
    input  [7:0] b,
    // input [1:0] btn,
    input clk,
    input rst,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);
    // assign fnd_com = 4'b1110;
    wire [7:0] w_sum;
    wire w_carry; 
    full_adder8 U_Adder (
        .a(a),
        .b(b),
        .sum(w_sum),
        .c_out(w_carry)
    );

    fnd_controller U_Fnd_CTRL (
        .sum({w_carry, w_sum}), // 1+8 bit -> 9bit
        // .digit_sel(btn),
        .clk(clk),
        .reset(rst),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)    
    );



endmodule
