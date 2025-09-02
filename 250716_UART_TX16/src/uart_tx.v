`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/15 13:20:56
// Design Name: 
// Module Name: uart_tx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_tx(
    input clk,
    input reset,
    input start,
    input b_tick,
    input [7:0] tx_data,
    output tx_busy,
    output tx
    );

// FSM ver2
if (1) begin
    localparam IDLE = 0, WAIT = 1, START = 2, DATA = 3, STOP = 4;
    reg [3:0] c_state, n_state;
    reg c_tx, n_tx;
    reg c_busy, n_busy;
    reg [2:0] c_bit_cnt, n_bit_cnt;

    assign tx = c_tx;
    assign tx_busy = c_busy;
    // state reg
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            c_state <= IDLE;
            c_tx <= 1'b1;
            c_busy <= 1'b0;
            c_bit_cnt <= 0;
        end else begin
            c_state <= n_state;
            c_tx <= n_tx;
            c_busy <= n_busy;
            c_bit_cnt <= n_bit_cnt;
        end
    end 
    // next state CL
    always @(*) begin
        n_state = c_state;
        n_tx = c_tx;
        n_busy = c_busy;
        n_bit_cnt = c_bit_cnt;
            case (c_state)
            IDLE: begin
                //(guswo tkdxodptj cnffurrkqtdmf soqhsoa)
                n_tx = 1'b1; // idle state is high, moore model output 
                n_busy = 1'b0; // not busy in idle state
                if (start == 1'b1) begin
                    n_bit_cnt = 0; // reset bit counter
                    n_busy = 1'b1; // set busy when start is pressed, mealy model output
                    n_state = WAIT;
                end
            end
            WAIT: begin
                if (b_tick == 1'b1) begin
                    n_state = START;
                end
            end
            START: begin
                n_tx = 1'b0; // start bit is low
                if (b_tick == 1'b1) begin
                    n_state = DATA;
                end
            end
            DATA: begin
                n_tx = tx_data[c_bit_cnt];
                if (b_tick == 1'b1) begin
                    if (c_bit_cnt == 7) begin
                        n_state = STOP; // if last bit is sent, go to stop state
                    end else begin
                        n_bit_cnt = c_bit_cnt + 1; // increment bit counter
                        n_state = DATA; // continue sending data bits
                    end
                end
            end
            STOP: begin
                n_tx = 1'b1; // stop bit is high
                if (b_tick == 1'b1) begin
                    n_state = IDLE; // go back to idle state
                end
            end
            endcase
    end
end
endmodule
