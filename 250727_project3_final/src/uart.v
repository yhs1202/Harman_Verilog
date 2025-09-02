`timescale 1ns / 1ps

module uart (
    input clk,
    input rst,
    input tx_start,

    input        rx,
    output [7:0] rx_data,
    output       rx_busy,
    output       rx_done,

    input  [7:0] tx_data,
    output       tx,
    output       tx_busy
);

    wire w_b_tick;


    uart_rx U_UART_RX (
        .clk(clk),
        .rst(rst),
        .b_tick(w_b_tick),
        .rx(rx),

        .rx_data(rx_data),
        .rx_busy(rx_busy),
        .rx_done(rx_done)
    );

    uart_tx U_UART_TX (
        .clk    (clk),
        .rst    (rst),
        .start  (tx_start),
        .b_tick (w_b_tick),
        .tx_data(tx_data),

        .tx_busy(tx_busy),
        .tx     (tx)
    );

    baud_tick_gen U_BAUD_TICK (
        .clk   (clk),
        .rst   (rst),
        .b_tick(w_b_tick)
    );


endmodule

module uart_rx (
    input        clk,
    input        rst,
    input        b_tick,
    input        rx,
    output [7:0] rx_data,
    output       rx_busy,
    output       rx_done
);

    localparam [1:0] IDLE = 2'b00, START = 2'b01, DATA = 2'b10, STOP = 2'b11;

    reg [1:0] c_state, n_state;
    reg [3:0] b_tick_cnt_reg, b_tick_cnt_next;
    reg [2:0] bit_cnt_reg, bit_cnt_next;
    reg [7:0] rx_data_reg, rx_data_next;                 // 바로 rx_data(출력)에 값을 넣으면 래치 발생 (특히 always내에서)
    reg rx_done_reg, rx_done_next;
    reg rx_busy_reg, rx_busy_next;

    // Output assign (연결)
    assign rx_data = rx_data_reg;
    assign rx_busy = rx_busy_reg;
    assign rx_done = rx_done_reg;

    // state register
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state        <= IDLE;
            b_tick_cnt_reg <= 0;
            rx_data_reg    <= 0;
            bit_cnt_reg    <= 0;
            rx_done_reg    <= 0;
            rx_busy_reg    <= 0;
        end else begin
            c_state        <= n_state;
            b_tick_cnt_reg <= b_tick_cnt_next;
            rx_data_reg    <= rx_data_next;
            bit_cnt_reg    <= bit_cnt_next;
            rx_done_reg    <= rx_done_next;
            rx_busy_reg    <= rx_busy_next;
        end

    end

    // CL
    always @(*) begin
        n_state         = c_state;
        b_tick_cnt_next = b_tick_cnt_reg;
        rx_data_next    = rx_data_reg;
        bit_cnt_next    = bit_cnt_reg;
        rx_done_next    = rx_done_reg;
        rx_busy_next    = rx_busy_reg;

        case (c_state)

            IDLE: begin
                rx_done_next = 1'b0;

                if(~rx)                         // rx == 0 > State = Start
                    begin
                    b_tick_cnt_next = 0;  // Receive 할때마다 초기화
                    bit_cnt_next    = 0;
                    rx_busy_next    = 1'b1;

                    n_state         = START;
                end
            end

            START: begin
                if (b_tick) begin
                    if (b_tick_cnt_reg == 7) begin
                        b_tick_cnt_next = 0;
                        n_state         = DATA;
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end

            DATA: begin
                if (b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        b_tick_cnt_next = 0;

                        rx_data_next = {rx, rx_data_reg[7:1]};

                        if (bit_cnt_reg == 7) begin
                            bit_cnt_next = 0;

                            n_state      = STOP;
                        end else begin
                            bit_cnt_next = bit_cnt_reg + 1;
                        end
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end

            STOP: begin
                if (b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        bit_cnt_next = 0;

                        //rx_busy_next    = 1'b0;
                        rx_done_next = 1'b1;

                        n_state      = IDLE;
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end else begin
                    n_state = STOP;
                end
            end
        endcase
    end

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
                    next_tx_busy = 1'b1;                // busy가 1 tick이라도 떨어져야 pop을 또 다시 요청 가능
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
                        tick_cnt_next = 4'h0;
                        next_state    = DATA;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end

            DATA: begin
                next_tx = tx_data_reg[0];                           // LSB Output > 출력 내보내는 곳 (tx_data_reg > next_tx > current_tx > tx)

                if (b_tick == 1'b1) begin
                    if (tick_cnt_reg == 15) begin
                        tick_cnt_next = 4'h0;

                        tx_data_next = tx_data_reg >> 1;            // Shift Register, 보낼 Data를 LSB로 계속 위치 시킨다.

                        if (current_bit_cnt == 7) begin
                            next_bit_cnt = 0;
                            next_state   = STOP;
                        end else begin
                            next_bit_cnt = current_bit_cnt + 1;
                            next_state   = DATA;
                        end
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                        next_state = DATA;
                    end
                end else begin
                    next_state = DATA;
                end
            end

            STOP: begin
                next_tx = 1'b1;

                if (b_tick == 1'b1) begin
                    if (tick_cnt_reg == 15) begin
                        tick_cnt_next = 0;
                        next_state = IDLE;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
        endcase
    end
endmodule


////////////////////////////////////////// Baud Tick Generator //////////////////////////////////////////
////////////////////////////////////////// Baud Tick Generator //////////////////////////////////////////
////////////////////////////////////////// Baud Tick Generator //////////////////////////////////////////
////////////////////////////////////////// Baud Tick Generator //////////////////////////////////////////
////////////////////////////////////////// Baud Tick Generator //////////////////////////////////////////

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
