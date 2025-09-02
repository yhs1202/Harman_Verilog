`timescale 1ns / 1ps

module tick_counter_watch #(
    parameter TICK_COUNT = 100,
    WIDTH = 7
) (
    input               clk,
    input               rst,
    input               en,     // SET MODE digit select
    input               clear,  // Btn_L
	input			    inc,    // Btn_U
	input			    dec,    // Btn_D
    input               i_tick,
    output              o_tick,
    output [WIDTH-1:0]  o_time
);
    // feedback
    reg [$clog2(TICK_COUNT)-1:0] counter_reg, counter_next;
    reg tick_reg, tick_next;
    reg clear_reg, en_reg, en_reg2;

    assign o_time = counter_reg;
    assign o_tick = tick_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= (WIDTH == 5) ? 12 : 0;     // watch mode initalization
            tick_reg    <= 0;
        end
        else begin
            counter_reg <= counter_next;
            tick_reg    <= tick_next;
        end
    end

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            en_reg <= 0;
            en_reg2 <= 0;
        end
        else begin
            en_reg <= en;
            en_reg2 <= en_reg;
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
        // Priority : clear > inc/dec
        if (clear && en_reg2) counter_next = (WIDTH == 5) ? 12 : 0;   // watch mode initalization
        
        if (en) begin
            if (inc) counter_next = (counter_reg < TICK_COUNT - 1) ? counter_reg + 1 : 0;
            else if (dec) counter_next = (counter_reg > 0) ? counter_reg - 1 : TICK_COUNT - 1;
        end



        // if (en) begin
        //     if (clear) begin
        //         counter_next = (WIDTH == 5) ? 12 : 0;   // watch mode initalization
        //     end
        //     if (inc) counter_next = (counter_reg < TICK_COUNT - 1) ? counter_reg + 1 : 0;
        //     else if (dec) counter_next = (counter_reg > 0) ? counter_reg - 1 : TICK_COUNT - 1;
        // end
    end

    // always @(*) begin
    //     counter_next = counter_reg;
    //     tick_next    = 1'b0;

    //     if (clear) begin
    //         if(en_reg2)
    //             counter_next = (WIDTH == 5) ? 12 : 0;
    //     end

    //     if (en) begin

    //         if (inc)
    //             counter_next = (counter_reg < TICK_COUNT - 1) ? counter_reg + 1 : 0;
    //         else if (dec)
    //             counter_next = (counter_reg > 0) ? counter_reg - 1 : TICK_COUNT - 1;
    //     end
    //     else if (i_tick) begin
    //         if (counter_reg == TICK_COUNT - 1) begin
    //             counter_next = 0;
    //             tick_next = 1'b1;
    //         end else begin
    //             counter_next = counter_reg + 1;
    //             tick_next = 1'b0;
    //         end
    //     end
    // end
endmodule
