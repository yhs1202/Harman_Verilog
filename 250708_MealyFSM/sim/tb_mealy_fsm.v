`timescale 1ns / 1ps

module tb_dut;
    reg  clk;
    reg  rst;
    reg  din_bit;
    wire dout_bit;

    mealy_fsm uut (
        .clk(clk),
        .rst(rst),
        .din_bit(din_bit),
        .dout_bit(dout_bit)
    );

    // 클럭 생성 (예: 20ns 주기)
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        din_bit = 0;

        #15 rst = 0;

        #5 din_bit = 1;
        #30 din_bit = 0;
        #10 din_bit = 1;
        #20 din_bit = 0;
        #40 din_bit = 1;
        #10 din_bit = 0;
        #30 din_bit = 1;
        #40 din_bit = 0;
        #10 din_bit = 1;
        #10 din_bit = 0;
        #30 din_bit = 1;
        #20 din_bit = 0;
        #100 $finish;
    end

endmodule
