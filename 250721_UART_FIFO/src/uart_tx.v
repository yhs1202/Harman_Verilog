`timescale 1ns / 1ps

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
    parameter [3:0] IDLE = 0, WAIT = 1, START = 2, DATA = 3, STOP = 4;
    reg [3:0] c_state, n_state;
    reg c_tx, n_tx;
    reg c_busy, n_busy;
    reg [2:0] c_bit_cnt, n_bit_cnt;
    reg [3:0] tick_cnt_reg, tick_cnt_next;
    reg [7:0] data_reg, data_next; // buffer for data bits for shift

    // output signals
    assign tx = c_tx;
    assign tx_busy = c_busy;
    // state reg
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            c_state <= IDLE;
            c_tx <= 1'b1;
            c_busy <= 1'b0;
            c_bit_cnt <= 0;
            tick_cnt_reg <= 4'h0;
            data_reg <= 8'h00;
        end else begin
            c_state <= n_state;
            c_tx <= n_tx;
            c_busy <= n_busy;
            c_bit_cnt <= n_bit_cnt;
            tick_cnt_reg <= tick_cnt_next;
            data_reg <= data_next;
        end
    end 
    // next state CL
    always @(*) begin
        n_state = c_state;
        n_tx = c_tx;
        n_busy = c_busy;
        n_bit_cnt = c_bit_cnt;
        tick_cnt_next = tick_cnt_reg;
        data_next = data_reg;
            case (c_state)
            IDLE: begin
                //(guswo tkdxodptj cnffurrkqtdmf soqhsoa)
                // idle state is high, moore model output 
                n_tx = 1'b1; 
                // not busy in idle state
                // n_busy = 1'b0; 
                tick_cnt_next = 4'h0; // reset tick counter
                if (start == 1'b1) begin
                    n_busy = 1'b1; // set busy when start is pressed, mealy model output
                    data_next = tx_data; // load data to be sent
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
                n_bit_cnt = 0; // reset bit counter
                if (b_tick == 1'b1) begin
                    if (tick_cnt_reg == 15) begin
                        n_state = DATA; // go to data state after start bit
                        tick_cnt_next = 0; // reset tick counter for data bits
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1; // increment tick counter
                    end
                end
            end
            DATA: begin
                n_tx = data_reg[0];
                if (b_tick) begin
                    if (tick_cnt_reg == 15) begin
                        data_next = data_reg >> 1; // send next data bit
                        tick_cnt_next = 4'h0; // reset tick counter for next bit
                        if (c_bit_cnt == 7) begin
                            n_state = STOP; // if last bit is sent, go to stop state
                        end else begin
                            n_bit_cnt = c_bit_cnt + 1; // increment bit counter
                            n_state = DATA; // continue sending data bits
                        end
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1; // increment tick counter
                    end
                end
            end
            STOP: begin
                n_tx = 1'b1; // stop bit is high
                if (b_tick == 1'b1) begin
                    if (tick_cnt_reg == 15) begin
                        n_busy = 1'b0; // clear busy flag after stop bit
                        n_state = IDLE; // go back to idle state after stop bit
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1; // increment tick counter
                    end
                end
            end
        endcase
    end
endmodule
