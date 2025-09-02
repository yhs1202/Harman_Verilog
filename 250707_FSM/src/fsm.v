`timescale 1ns / 1ps
module fsm(
    input clk,
    input reset,
    input sw,
    output reg [1:0] led
    );

    // state
    parameter STOP = 0, RUN = 1;

    // state register
    reg current_state, next_state;


    // sequential logic
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            current_state <= STOP;
        end else begin
            current_state <= next_state;    // !reset -> state = next_state
        end 
    end


    // combinational logic
    always @(*) begin
        // loop-back
        next_state = current_state;
        case (current_state)
            STOP: begin
                if (sw == 1'b1) next_state = RUN;
            end
            RUN: begin
                if (sw == 1'b0) next_state = STOP;
            end
            default: next_state = current_state;
        endcase
    end

    // output combinational logic
    always @(*) begin
        case (current_state)
            STOP: led = 2'b10;
            RUN: led = 2'b01;
            default: led = 2'b10;
        endcase
    end
endmodule
