`timescale 1ns / 1ps
module SR04_Controller_unit (
    input clk, rst, tick,
    input start, echo,
    output trig,
    output [8:0] distance,
    output [2:0] state
);

    localparam [2:0] IDLE = 3'b000, 
                    START = 3'b001, 
                    WAIT = 3'b010, 
                    DETECT = 3'b011,
                    CALC = 3'b100;
    reg [2:0] c_state, n_state;
    reg trig_reg, trig_next;
    reg [$clog2(400*58)-1:0] tick_count_reg, tick_count_next; // 400

    assign trig = trig_reg;
    assign state = c_state;
    assign distance = tick_count_reg / 58; // Calculate distance in cm (assuming 1 tick = 58 us) 



    always @(posedge clk or posedge rst) begin
        if (rst) begin
            c_state <= IDLE;
            tick_count_reg <= 0;
            trig_reg <= 0;
        end else begin
            c_state <= n_state;
            trig_reg <= trig_next;
            tick_count_reg <= tick_count_next;
        end
    end

    always @(*) begin
        n_state = c_state;
        trig_next = trig_reg;
        tick_count_next = tick_count_reg;
        case (c_state)
            IDLE: begin
                trig_next = 0;
                if (start) begin
                    trig_next = 1; // Trigger the ultrasonic sensor
                    tick_count_next = 0; // Reset tick count
                    n_state = START;
                end
            end
            START: begin
                if (tick) begin
                    if (tick_count_reg == 11) begin // Wait for 10 ticks (1ms)
                    tick_count_next = 0; // Reset tick count
                    trig_next = 0; // Stop triggering after 1ms
                    n_state = WAIT; // Move to wait state
                end else begin
                    tick_count_next = tick_count_reg + 1;
                    end
                end
            end
            WAIT: begin
                if (tick) begin
                    if(echo) begin
                        n_state = DETECT;
                        tick_count_next = 0;
                    end
                end
            end
            DETECT: begin
                if (tick) begin
                    if (echo) begin
                        tick_count_next = tick_count_reg + 1;
                    end else if (~echo) begin
                        n_state = CALC; // echo fell
                    end else begin
                        tick_count_next = tick_count_reg; // Keep the current tick count
                    end
                end
            end
            CALC: begin
                // tick_count_next = 0; // Reset tick count for next measurement
                trig_next = 0; // Ensure trigger is low after calculation
                n_state = IDLE; // Go back to idle state after calculation 
            end
        endcase
    end
endmodule