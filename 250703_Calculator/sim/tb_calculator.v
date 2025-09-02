`timescale 1ns / 1ps
module tb_calculator ();
    reg [7:0] a, b;
    reg clk, rst;
    wire [7:0] fnd_data;
    wire [3:0] fnd_com;

    
    wire [16:0] clk_div_counter_debug;
    wire clk_1khz_debug;
    wire [1:0] counter4_reg_debug;
    wire [1:0] digit_sel_debug;

    calculator dut (
        .a(a),
        .b(b),
        .clk(clk),
        .rst(rst),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );

    clk_div uut_clk_div (
        .clk(clk),
        .reset(rst),
        .o_1khz(clk_1khz_debug)
    );

    counter_4 uut_counter4 (
        .clk(clk_1khz_debug),
        .reset(rst),
        .digit_sel(digit_sel_debug)
    );

    assign clk_div_counter_debug = uut_clk_div.r_counter;
    assign counter4_reg_debug = uut_counter4.r_counter;

    always #5 clk = ~clk;
    initial begin
        // Initialize inputs
        clk = 0;
        rst = 1;
        a   = 8'd0;
        b   = 8'd0;

        // Apply reset
        #100;
        rst = 0;

        // Test case 1: a = 1, b = 10
        a   = 8'd1;
        b   = 8'd10;
        #100;

        // Test case 2: a = 128, b = 127 (overflow)
        a = 8'd128;
        b = 8'd127;
        #100;

        // Test case 3: a = 200, b = 55
        a = 8'd200;
        b = 8'd55;
        #100;

        // Test case 4: a = 256, b = 255 (overflow)
        a = 8'd255;
        b = 8'd255;
        #100;

        // Finish simulation
        $finish;
    end

endmodule

