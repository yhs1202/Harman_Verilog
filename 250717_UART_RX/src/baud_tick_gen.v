`timescale 1ns / 1ps
module baud_tick_gen(
    input clk,
    input reset,
    output b_tick
    );

    // tick: 100Mhz -> 9600 bps
    // 100000000/9600 = 10416.xx -> 10417 clk need
    parameter BAUD_COUNT = 100_000_000/(9600 * 16);
    reg [$clog2(BAUD_COUNT-1)-1:0] tick_counter;
    reg r_tick; // b_tick

    assign b_tick = r_tick;
    // w/o feedback
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            tick_counter <= 0;
            r_tick <= 0;
        end else begin
            if (tick_counter == BAUD_COUNT-1) begin
                tick_counter <= 0;
                r_tick <= 1'b1;
            end else begin
                tick_counter <= tick_counter + 1;
                r_tick <= 1'b0;
            end           
        end
    end
endmodule
