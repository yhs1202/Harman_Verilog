`timescale 1ns / 1ps
module DHT11_controller_unit(
    input clk, rst, tick,
    input start,
    output [39:0] dht_data_out,
    output [2:0] state,
    output valid,
    output done,

    // tx, rx
    inout dht_io
    );

    // tx 3state control
    reg tx_en_reg, tx_en_next; // Transmit enable signal, ouput to DHT11
    reg tx_reg, tx_next; // Data to be sent to DHT11

    // tri state buffer
    assign dht_io = (tx_en_reg) ? tx_reg : 1'bz; // DHT11 data line is driven low when transmitting

    // rx
    wire rx;

    reg [2:0] c_state, n_state; // Current and next state
    reg [5:0] bit_count_reg, bit_count_next; // Bit counter for transmission
    reg [39:0] dht_data_reg, dht_data_next; // Received data from DHT11
    reg valid_reg, valid_next; // Valid signal indicating data is ready
    reg done_reg, done_next; // Done signal indicating transmission is complete
    reg [$clog2(8)-1:0] tick_count_reg, tick_count_next;


    localparam [3:0] IDLE = 4'b0000,
                    START = 4'b0001,
                    WAIT = 4'b0010,
                    SYNC_L = 4'b0011,
                    SYNC_H = 4'b0100,
                    DATA_SYNC = 4'b0101,
                    DATA = 4'b0110,
                    CALC = 4'b0111,
                    STOP_SYNC = 4'b1000,
                    STOP = 4'b1001;

    assign dht_data_out = dht_data_reg;
    assign valid = valid_reg;
    assign done = done_reg;
    assign state = c_state;
    assign tx_en = tx_en_reg; //?
    assign tx = tx_reg; //?
    assign rx = dht_io;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            c_state <= IDLE;
            valid_reg <= 0;
            done_reg <= 0;
            dht_data_reg <= 0;
            tx_en_reg <= 0;
            tx_reg <= 0;
            tick_count_reg <= 0;
            bit_count_reg <= 0;
        end else begin
            c_state <= n_state;
            valid_reg <= valid_next;
            done_reg <= done_next;
            dht_data_reg <= dht_data_next;
            tx_en_reg <= tx_en_next;
            tx_reg <= tx_next;
            tick_count_reg <= tick_count_next;
            bit_count_reg <= bit_count_next;
        end
    end

    always @(*) begin
        n_state = c_state;
        valid_next = valid_reg;
        done_next = done_reg;
        dht_data_next = dht_data_reg;
        tx_en_next = tx_en_reg;
        tx_next = tx_reg;
        tick_count_next = tick_count_reg;
        bit_count_next = bit_count_reg;

        case (c_state)
            IDLE: begin
                tx_next = 1;
                valid_next = 0;
                if (start) begin
                    tick_count_next = 0; // Reset tick count
                    tx_next = 0;
                    n_state = START;
                end
            end
            START: begin
                if (tick) begin
                    if (tick_count_reg == 18000) begin // Wait for 18ms = 18*1000 us
                        tick_count_next = 0; // Reset tick count
                        tx_next = 1;
                        n_state = WAIT; // Move to wait state
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                        end
                end
            end
            WAIT: begin
                if (tick) begin
                    if (tick_count_reg == 30) begin
                        tick_count_next = 0; // Reset tick count
                        tx_en_next = 0;
                        n_state = SYNC_L; // Move to wait state
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                        end
                end
            end
            SYNC_L: begin
                if (tick) begin
                    if (rx && tick_count_reg >= 50) begin
                        tick_count_next = 0; // Reset tick count
                        n_state = SYNC_H; // Move to wait state
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                        end
                end
            end
            SYNC_H: begin
                if (tick) begin
                    if (!rx && tick_count_reg == 50) begin
                        tick_count_next = 0;
                        n_state = DATA_SYNC;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
            DATA_SYNC: begin
                // 50us
                // checksum
                if (tick) begin
                    if (!rx && tick_count_reg == 50) begin
                        tick_count_next = 0;
                        n_state = DATA;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end                        
            DATA: begin
                if(tick) begin
                    if(!rx) begin
                        n_state = CALC;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
            CALC: begin
                if (!rx && bit_count_reg == 39) begin
                    tick_count_next = 0;
                    bit_count_next = 0;
                    n_state = STOP_SYNC;

                    // valid
                    valid_next = (dht_data_reg[7:0] == dht_data_reg[39:32] + dht_data_reg[31:24] + dht_data_reg[23:16] + dht_data_reg[15:8]) ? 1 : 0;
                end else begin
                    n_state = DATA_SYNC;
                    bit_count_next = bit_count_reg + 1;
                end
                if(tick_count_reg >= 30) begin
                    dht_data_next = {dht_data_reg[38:0], 1'b1};
                end else begin
                    dht_data_next = {dht_data_reg[38:0], 1'b0};
                end
            end
            STOP_SYNC: begin
                if (tick) begin
                    if (tick_count_reg == 50) begin
                        tick_count_next = 0;
                        done_next = 1;
                        n_state = STOP;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
            STOP: begin
                tx_en_next = 1;
                done_next = 0;
                n_state = IDLE;
            end
        endcase
    end
endmodule