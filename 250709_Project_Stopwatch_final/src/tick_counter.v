`timescale 1ns / 1ps

module tick_counter #(
    parameter TICK_COUNT = 100,
    WIDTH = 7
) (
    input               clk,
    input               rst,
    input               clear,
    input               i_tick,
    output              o_tick,
    output [WIDTH-1:0]  o_time
);
    // feedback
    reg [$clog2(TICK_COUNT)-1:0] counter_reg, counter_next;
    reg tick_reg, tick_next;

    assign o_time = counter_reg;
    assign o_tick = tick_reg;

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            counter_reg <= 0;
            tick_reg    <= 0;
        end
        else begin
            counter_reg <= counter_next;
            tick_reg    <= tick_next;
        end
    end

    always @(*) begin
        counter_next = counter_reg;
        tick_next    = 1'b0;
        // i_tick = 1 -> increase count
        if (i_tick) begin
            if(counter_reg == TICK_COUNT - 1) begin
                counter_next = 0;
                tick_next    = 1'b1;
            end
            else begin
                counter_next = counter_reg + 1;
                tick_next    = 1'b0;
            end
        end

        if (clear) begin
            counter_next = 0;
        end
    end

endmodule
