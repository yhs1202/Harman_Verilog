`timescale 1ns / 1ps

module top (
    input clk,
    input rst,
    input sw_1,
    input sw_2,
    input sw_3,
    input btn_R,
    input btn_L,
    input btn_U,
    input btn_D,

    input  rx,
    output tx,

    output [3:0] fnd_com,
    output [7:0] fnd_data,
    output [8:0] led_data
);
    wire [7:0] w_rx_fifo_data;


    wire w_rx_empty, w_cmd_m, w_cmd_L, w_cmd_s, w_cmd_r, w_cmd_c, w_cmd_H, w_cmd_M, w_cmd_S;
    wire w_rx_done;

    cmd_control U_CMD_CTRL (
        .clk(clk),
        .rst(rst),

        .rx_fifo_data(w_rx_fifo_data),
        .flag(w_rx_empty),

        .cmd_m(w_cmd_m),
        .cmd_r(w_cmd_r),
        .cmd_c(w_cmd_c),
        .cmd_H(w_cmd_H),
        .cmd_M(w_cmd_M),
        .cmd_S(w_cmd_S),
        .cmd_L(w_cmd_L),
        .cmd_s(w_cmd_s)

    );

    All_watch U_WATCH (
        .clk  (clk),
        .rst  (rst),
        .sw_1 (sw_1),
        .sw_2 (sw_2),
        .sw_3 (sw_3),
        .btn_R(btn_R),
        .btn_L(btn_L),
        .btn_U(btn_U),
        .btn_D(btn_D),

        .rx_fifo_data(w_rx_fifo_data),
        .rx_empty(w_rx_empty),

        .cmd_m(w_cmd_m),
        .cmd_r(w_cmd_r),
        .cmd_c(w_cmd_c),
        .cmd_H(w_cmd_H),
        .cmd_M(w_cmd_M),
        .cmd_S(w_cmd_S),
        .cmd_L(w_cmd_L),
        .cmd_s(w_cmd_s),

        .fnd_com (fnd_com),
        .fnd_data(fnd_data),
        .led_data(led_data)
    );

    uart_tx_rx U_UART (
        .clk(clk),
        .rst(rst),
        .rx (rx),
        .tx (tx),

        .rx_fifo_data(w_rx_fifo_data),
        .rx_empty(w_rx_empty),
        .rx_done(w_rx_done)
    );

endmodule


module cmd_control (
    input clk,
    input rst,

    input [7:0] rx_fifo_data,
    input       flag,   // rx_empty flag

    output reg cmd_L,   // LED ON/OFF
    output reg cmd_H,   // Hour set
    output reg cmd_M,   // Minute set
    output reg cmd_S,   // Second set
    output reg cmd_c,   // Clear
    output reg cmd_m,   // Watch/Stopwatch mode toggle in mode 1
    output reg cmd_r,   // Run/Stop
    output reg cmd_s,   // hour,min/sec,msec mode toggle
    output reg cmd_1,   // mode1 (Watch/Stopwatch)
    output reg cmd_2,   // mode2 (Ultrasensor)
    output reg cmd_3,   // mode3 (DHT11)
    output reg cmd_at   // display fnd data to uart
);

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            cmd_L <= 1'b0;
            cmd_H <= 1'b0;
            cmd_M <= 1'b0;
            cmd_S <= 1'b0;
            cmd_c <= 1'b0;
            cmd_m <= 1'b0;
            cmd_r <= 1'b0;
            cmd_s <= 1'b0;
            cmd_1 <= 1'b0;
            cmd_2 <= 1'b0;
            cmd_3 <= 1'b0;
            cmd_at <= 1'b0;
        end else begin
            if (flag == 0) begin
                case (rx_fifo_data)
                    "L": cmd_L <= ~cmd_L;
                    "H": cmd_H <= 1'b1;
                    "M": cmd_M <= 1'b1;
                    "S": cmd_S <= 1'b1;
                    "c": cmd_c <= 1'b1;
                    "m": cmd_m <= ~cmd_m;
                    "r": cmd_r <= 1'b1;
                    "s": cmd_s <= ~cmd_s;
                    "1": cmd_1 <= 1'b1;
                    "2": cmd_2 <= 1'b1;
                    "3": cmd_3 <= 1'b1;
                    "@": cmd_at <= 1'b1;
                endcase
            end else begin
                cmd_L <= 1'b0;
                cmd_H <= 1'b0;
                cmd_M <= 1'b0;
                cmd_S <= 1'b0;
                cmd_c <= 1'b0;
                cmd_m <= 1'b0;
                cmd_r <= 1'b0;
                cmd_s <= 1'b0;
                cmd_1 <= 1'b0;
                cmd_2 <= 1'b0;
                cmd_3 <= 1'b0;
                cmd_at <= 1'b0;
            end
        end
    end
endmodule
