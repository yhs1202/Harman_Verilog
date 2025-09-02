`timescale 1ns / 1ps

module uart_sender (
    input clk,
    rst,
    input start,

    input [8:0] distance,

    // output reg tx_done,
    output tx
);

    wire w_b_tick, w_tx_busy;

    wire [7:0] digit_100 = 8'd48 + (distance / 100);
    wire [7:0] digit_10 = 8'd48 + ((distance % 100) / 10);
    wire [7:0] digit_1 = 8'd48 + (distance % 10);

    parameter [2:0] IDLE = 0, SEND_100 = 1, WAIT1 = 2, SEND_10 = 3,  WAIT2 = 4, SEND_1 = 5, WAIT3 = 6, DONE = 7;
    reg [2:0] state;
    reg [7:0] tx_data;
    reg       tx_start;


    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state    <= IDLE;
            tx_start <= 0;
            tx_data  <= 0;
            //          tx_done   <= 0;
        end else begin
            tx_start <= 0;

            case (state)
                IDLE: begin
                    //                 tx_done <= 0;   
                    if (start) begin
                        state <= SEND_100;
                    end
                end

                SEND_100: begin
                    if (!w_tx_busy) begin
                        tx_data  <= digit_100;
                        tx_start <= 1;
                        state    <= WAIT1;
                    end
                end

                WAIT1: begin
                    if (w_tx_busy) state <= SEND_10;
                end

                SEND_10: begin
                    if (!w_tx_busy) begin
                        tx_data  <= digit_10;
                        tx_start <= 1;
                        state    <= WAIT2;
                    end
                end

                WAIT2: begin
                    if (w_tx_busy) state <= SEND_1;
                end

                SEND_1: begin
                    if (!w_tx_busy) begin
                        tx_data  <= digit_1;
                        tx_start <= 1;
                        state    <= WAIT3;
                    end
                end

                WAIT3: begin
                    if (w_tx_busy) state <= DONE;
                end

                DONE: begin
                    if (!w_tx_busy) begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end


    uart_tx U_UART_TX (
        .clk    (clk),
        .rst    (rst),
        .start  (tx_start),
        .b_tick (w_b_tick),
        .tx_data(tx_data),

        .tx_busy(w_tx_busy),
        .tx     (tx)
    );


    baud_tick_gen U_BAUD_TICK (
        .clk   (clk),
        .rst   (rst),
        .b_tick(w_b_tick)
    );


endmodule

module uart_tx (
    input       clk,
    rst,
    input       start,
    input       b_tick,
    input [7:0] tx_data,

    output tx_busy,
    output tx
);

    // Define State   
    parameter [3:0] IDLE = 0, WAIT = 1, START = 2, DATA = 3, STOP = 4;      // current_state와 비트 수를 맞춰줘야 한다. [3:0] > 래치 방지


    //State
    reg [3:0] current_state, next_state;
    reg current_tx, next_tx;
    reg current_tx_busy, next_tx_busy;
    reg [2:0] current_bit_cnt, next_bit_cnt;

    reg [3:0] tick_cnt_reg, tick_cnt_next;  // reg = current

    reg [7:0] tx_data_reg, tx_data_next;  // reg = current

    // 모듈 Ouput과 연결
    assign tx      = current_tx;
    assign tx_busy = current_tx_busy;

    //순차논리
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            current_state   <= IDLE;
            current_tx      <= 1'b1;  // TX 초기값 = 1
            current_tx_busy <= 1'b0;  // Busy 초기값 = 0
            current_bit_cnt <= 0;
            tick_cnt_reg    <= 4'h0;
            tx_data_reg     <= 8'h00;
        end else begin
            current_state   <= next_state;
            current_tx      <= next_tx;
            current_tx_busy <= next_tx_busy;
            current_bit_cnt <= next_bit_cnt;
            tick_cnt_reg    <= tick_cnt_next;
            tx_data_reg     <= tx_data_next;  /////////////////////////////
        end
    end



    always @(*) begin

        next_state    = current_state;  // 래치 방지
        next_tx       = current_tx;
        next_tx_busy  = current_tx_busy;
        next_bit_cnt  = current_bit_cnt;
        tick_cnt_next = tick_cnt_reg;
        tx_data_next  = tx_data_reg;  /////////////////////////////

        case (current_state)
            IDLE: begin
                next_tx          = 1'b1;                // Moore Machine (현재 State 만으로 출력) 
                next_tx_busy = 1'b0;
                tick_cnt_next = 4'h0;
                tx_data_next = 8'h00;  /////////////////////////////

                if (start == 1'b1) begin
                    next_tx_busy = 1'b1;
                    tx_data_next = tx_data;  /////////////////////////////
                    next_state   = WAIT;                // Mealy Machine (State는 물론 입력값(Start == 1)으로도 출력 가능)
                end
            end

            WAIT: begin
                if (b_tick == 1'b1) begin
                    next_state = START;
                end
            end

            START: begin
                next_tx      = 1'b0;                         // DATA State에서 사용할 next_bit_cnt를 0으로 초기화
                next_bit_cnt = 0;

                if (b_tick == 1'b1) begin
                    if (tick_cnt_reg == 15) begin
                        next_state    = DATA;
                        tick_cnt_next = 4'h0;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end

            DATA: begin

                next_tx = tx_data_reg[0];                           // LSB Output ////////////출력 내보내는 곳/////////////////

                if (b_tick == 1'b1) begin
                    if (tick_cnt_reg == 15) begin
                        tx_data_next = tx_data_reg >> 1;            // Shift Register /////////////////////////////
                        tick_cnt_next = 4'h0;

                        if (current_bit_cnt == 7) begin
                            next_state = STOP;
                        end else begin
                            next_bit_cnt = current_bit_cnt + 1;
                            next_state   = DATA;
                        end
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end

                end
            end

            STOP: begin
                next_tx = 1'b1;

                if (b_tick == 1'b1) begin
                    if (tick_cnt_reg == 15) begin
                        next_state = IDLE;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
        endcase
    end
endmodule


module baud_tick_gen (
    input  clk,
    rst,
    output b_tick
);
    // tick bps : 9600
    parameter BAUD_COUNT = (100_000_000 / (9600 * 16)) - 1;
    reg [$clog2(BAUD_COUNT)-1:0] tick_counter;
    reg                          r_tick;

    assign b_tick = r_tick;

    //  순차논리
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            tick_counter <= 0;
            r_tick       <= 0;
        end else begin
            if (tick_counter == BAUD_COUNT) begin
                tick_counter <= 0;
                r_tick       <= 1'b1;
            end else begin
                tick_counter <= tick_counter + 1;
                r_tick       <= 1'b0;
            end
        end
    end
endmodule
