`timescale 1ns / 1ps

module tb_uart_cmd_top();

    reg clk, rst;
    reg rx; // UART receive line
    reg [15:0] value;
    wire cmd_L, cmd_H, cmd_M, cmd_S, cmd_c, cmd_m, cmd_r, cmd_s, cmd_1, cmd_2, cmd_3, cmd_at;
    wire tx;

    uart_cmd_top uut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tx(tx),
        .cmd_L(cmd_L),
        .cmd_H(cmd_H),
        .cmd_M(cmd_M),
        .cmd_S(cmd_S),
        .cmd_c(cmd_c),
        .cmd_m(cmd_m),
        .cmd_r(cmd_r),
        .cmd_s(cmd_s),
        .cmd_1(cmd_1),
        .cmd_2(cmd_2),
        .cmd_3(cmd_3),
        .cmd_at(cmd_at),
        .value(value)
    );

always #5 clk = ~clk;

// UART 9600bps -> 1bit = 104.167us = 104167ns
    parameter BAUD_PERIOD = 104167;

    task send_uart_byte(input [7:0] data);
        integer i;
        begin
            // Start bit
            rx <= 0;
            #(BAUD_PERIOD);

            // Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                rx <= data[i];
                #(BAUD_PERIOD);
            end

            // Stop bit
            rx <= 1;
            #(BAUD_PERIOD);
        end
    endtask

    initial begin
        clk = 0;
        rst = 1;
        rx = 1;
        value = 16'b0000_0011_0100_0010; // Example data to send
        #100;
        rst = 0;
        #100;

        send_uart_byte("L");
        # 500;
        send_uart_byte("H");
        # 500;
        send_uart_byte("M");
        # 500;
        send_uart_byte("S");
        # 500;
        send_uart_byte("c");
        # 500;
        send_uart_byte("m");
        # 500;
        send_uart_byte("r");
        # 500;
        send_uart_byte("s");
        # 500;
        send_uart_byte("1");
        # 500;
        send_uart_byte("@");
        #(20*9* BAUD_PERIOD);
        # 500;
        send_uart_byte("2");
        # 500;
        send_uart_byte("@");
        #(20*9* BAUD_PERIOD);
        # 500;
        send_uart_byte("3");
        # 500;
        send_uart_byte("@");
        #(20*9* BAUD_PERIOD);
        # 500;

        wait(cmd_at); 

        #(BAUD_PERIOD);
        # 500;
        $stop;
    end

endmodule
