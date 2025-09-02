`timescale 1ns / 1ps

module SR04_Control_Unit (
    input clk,
    rst,
    input db_start,
    input freq_tick_1mhz_1us,
    input echo,

    output       trig,
    tx_start,
    output [8:0] distance  // 400cm = 1_1001_0000 = 9bit
);
    reg [2:0] c_state, n_state;
    reg trig_reg, trig_next;
    reg [$clog2(400*58)-1:0] tick_counter_reg, tick_counter_next;
    reg [8:0] distance_reg, distance_next;
    reg tx_start_reg, tx_start_next;

    assign trig = trig_reg;
    assign distance = distance_reg;
    assign tx_start = tx_start_reg;


    parameter [2:0] IDLE = 0, START = 1, WAIT = 2, DETECT = 3, CAL = 4;


    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state          <= 0;
            trig_reg         <= 0;
            tick_counter_reg <= 0;
            distance_reg     <= 0;
            tx_start_reg     <= 0;
        end else begin
            c_state          <= n_state;
            trig_reg         <= trig_next;
            tick_counter_reg <= tick_counter_next;
            distance_reg     <= distance_next;
            tx_start_reg     <= tx_start_next;
        end
    end


    always @(*) begin
        n_state           = c_state;
        trig_next         = trig_reg;
        tick_counter_next = tick_counter_reg;
        distance_next     = distance_reg;
        tx_start_next     = tx_start_reg;

        case (c_state)
            IDLE: begin
                trig_next     = 1'b0;
                tx_start_next = 1'b0;

                if (db_start) begin
                    trig_next = 1'b1;
                    n_state   = START;
                end
            end

            START: begin
                if (freq_tick_1mhz_1us) begin
                    if(tick_counter_reg == 10)              // trig 10us 필요
                        begin
                        trig_next         = 1'b0;
                        tick_counter_next = 0;
                        n_state           = WAIT;
                    end else tick_counter_next = tick_counter_reg + 1;
                end
            end

            WAIT :                                              // echo = high가 올때까지 WAIT
                begin
                if (echo) begin
                    tick_counter_next = 0;
                    n_state = DETECT;
                end else begin
                    if(tick_counter_reg > 3200)       // 8 cycle sonic burst = 8 * 40khz = 8 * 400us 이후까지 echo 없으면 초기화
                        begin
                        tick_counter_next = 0;
                        n_state = IDLE;
                    end
                end

                if (freq_tick_1mhz_1us)
                    tick_counter_next = tick_counter_reg + 1;

            end
            DETECT: begin
                if (freq_tick_1mhz_1us)  // echo pulse poseedge timing
                    tick_counter_next = tick_counter_reg + 1;

                if (!echo) n_state = CAL;
            end

            CAL: begin
                if(tick_counter_reg > 120)          // 최소 측정 거리 2cm 보다 길게 감지한 경우만
                    begin
                    distance_next = tick_counter_reg / 58;  // 대안 assign distance_next = tick_counter_reg / 58
                    tick_counter_next = 0;
                    tx_start_next     = 1'b1;       // TX 시작 명령 (계산거리 전송)
                    n_state = IDLE;
                end else begin
                    tick_counter_next = 0;
                    n_state           = IDLE;
                end
            end

            default: n_state = IDLE;

        endcase
    end
endmodule
