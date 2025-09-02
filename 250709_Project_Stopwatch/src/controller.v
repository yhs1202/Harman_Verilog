`timescale 1ns / 1ps
module controller(
    input clk, rst,
    input btn_L, btn_R,
    // input btn_U, btn_D,

    output run_stop, // current == RUN
    output clear
    );

    // fsm
    // parameter state define
    parameter STOP = 3'b000, RUN = 3'b001, CLEAR = 3'b010;

    // state
    reg [2:0] current_state, next_state;
    reg current_clear, next_clear;


    // state register SL
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            current_state <= STOP;
            current_clear <= 0;
        end else begin
            current_state <= next_state;
            current_clear <= next_clear;
        end
    end

    // next Comb-Logic
    always @(*) begin
        // init (To avoid latch)
        next_state = current_state;
        next_clear = current_clear;
        case (current_state)
            STOP: begin
                next_clear = 0;
                if (btn_R) next_state = RUN;
                else if (btn_L) next_state = CLEAR;
                else next_state = current_state;
            end
            RUN: begin
                if (btn_R) next_state = STOP;
                else if (btn_L) next_state = CLEAR;
                else next_state = current_state;
            end
            CLEAR: begin
                next_state = STOP;
                next_clear = 1; // next posedge clk
            end
        endcase
    end

    assign run_stop = (current_state == RUN) ? 1 : 0;
    assign clear = current_clear;

endmodule
