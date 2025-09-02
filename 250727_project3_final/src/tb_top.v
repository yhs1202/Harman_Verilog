`timescale 1ns / 1ps

module tb_top ();

    reg clk, rst;
    reg [7:0] input_button;

    reg rx;
    wire tx;

    top dut (
        .clk  (clk),
        .rst  (rst),
        .sw_1 (),
        .sw_2 (),
        .sw_3 (),
        .btn_R(),
        .btn_L(),
        .btn_U(),
        .btn_D(),

        .rx(rx),
        .tx(tx),

        .fnd_com (),
        .fnd_data(),
        .led_data()
    );

    always #5 clk = ~clk;

    initial begin
        #0;
        clk = 0;
        rst = 1;
        rx = 1;
        input_button = 0;

        #10;
        rst = 0;

        input_button = "r";
        tsk_input_button(input_button);

        input_button = "c";
        tsk_input_button(input_button);

        input_button = "H";
        tsk_input_button(input_button);

        input_button = "M";
        tsk_input_button(input_button);

        input_button = "S";
        tsk_input_button(input_button);

        input_button = "s";
        tsk_input_button(input_button);

        input_button = "s";
        tsk_input_button(input_button);

        input_button = "m";
        tsk_input_button(input_button);

        input_button = "m";
        tsk_input_button(input_button);

        input_button = "L";
        tsk_input_button(input_button);

        input_button = "L";
        tsk_input_button(input_button);

    end

    task tsk_input_button(input [7:0] input_button);
        integer i;

        begin
            rx = 0;  // UART RX Start bit
            #(104166);
            for (i = 0; i < 8; i = i + 1) begin
                rx = input_button[i];
                #(104166);
            end
            rx = 1;  // UART RX stopbit
            #(104166);
        end
    endtask
endmodule
