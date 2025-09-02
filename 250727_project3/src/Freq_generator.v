`timescale 1ns / 1ps

module Freq_generator (
    input clk,
    rst,

    output tick_1mhz_1us
);

    reg [$clog2(100)-1:0] counter;
    reg tick;

    assign tick_1mhz_1us = tick;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter <= 0;
            tick    <= 1'b0;
        end else begin
            if (counter == (100 - 1)) begin
                counter <= 0;
                tick    <= 1'b1;
            end else begin
                counter <= counter + 1;
                tick    <= 1'b0;
            end
        end

    end


endmodule
