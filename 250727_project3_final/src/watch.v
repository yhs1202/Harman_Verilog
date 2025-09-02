    `timescale 1ns / 1ps

    module watch
    (
        input clk,
        input rst,
        input btn_L, btn_R, btn_U, btn_D,

        output [6:0] w_w_msec, [5:0] w_w_sec, [5:0] w_w_min, [4:0] w_w_hour
    );
    
        wire w_start, w_clear, w_inc_sec, w_inc_min, w_inc_hour;

    watch_dp U_W_DP
    (
        .clk(clk),
        .rst(rst),
        .start(w_start),
        .clear(w_clear),
        .inc_sec(w_inc_sec),
        .inc_min(w_inc_min),
        .inc_hour(w_inc_hour),

        .msec(w_w_msec),
        .sec(w_w_sec),
        .min(w_w_min),
        .hour(w_w_hour)
    );

    watch_cu U_WATCH_CU
    (
        .clk(clk),
        .rst(rst),
        .start_clear(btn_R),
        .inc_sec(btn_D),
        .inc_min(btn_L),
        .inc_hour(btn_U),

        .o_start(w_start),
        .o_clear(w_clear),
        .o_inc_sec(w_inc_sec),
        .o_inc_min(w_inc_min),
        .o_inc_hour(w_inc_hour)
    );

 
    endmodule

    module watch_cu (
        input clk, rst,
        input start_clear, inc_sec, inc_min, inc_hour,

        output o_clear, o_start, o_inc_sec, o_inc_min, o_inc_hour
    );
        
        
    // FSM

    parameter   IDLE = 3'b000, CLEAR = 3'b001, START = 3'b010, HOUR = 3'b011, MIN = 3'b100, SEC = 3'b101;

    reg [2:0] current_state, next_state;

    always @(posedge clk, posedge rst) 
    begin
        if(rst)
        begin
           current_state <= CLEAR;
        end

        else
        begin
           current_state <= next_state;
        end   
    end


/////////////////// Time value INC

    reg  btn_U_reg, btn_L_reg, btn_D_reg;
    wire inc_edge_hour, inc_edge_min, inc_edge_sec;

    always @(posedge clk, posedge rst) 
    begin
        if(rst)
        begin
            btn_U_reg <= 1'b0;
            btn_L_reg <= 1'b0;
            btn_D_reg <= 1'b0;
        end 

        else
        begin
            btn_U_reg <= inc_hour;
            btn_L_reg <= inc_min;
            btn_D_reg <= inc_sec;
        end
    end

    assign inc_edge_hour = (current_state == IDLE || current_state == CLEAR) && (inc_hour && !btn_U_reg);
    assign inc_edge_min  = (current_state == IDLE || current_state == CLEAR) && (inc_min  && !btn_L_reg);
    assign inc_edge_sec  = (current_state == IDLE || current_state == CLEAR) && (inc_sec  && !btn_D_reg);


    always @(*) 
    begin
        next_state = current_state;

        case(current_state)
            IDLE:
            begin
                if     (start_clear   == 1'b1)  next_state = START;
                else if(inc_edge_hour == 1'b1)  next_state = HOUR ;
                else if(inc_edge_min  == 1'b1)  next_state = MIN  ;
                else if(inc_edge_sec  == 1'b1)  next_state = SEC  ;
            end

            CLEAR:  next_state = IDLE;

            START:
            begin
                if(start_clear == 1'b1)
                begin
                    next_state = CLEAR;
                end
            end

            HOUR:  next_state = IDLE;
            MIN:   next_state = IDLE;
            SEC:   next_state = IDLE;

            default : next_state = IDLE;
            
        endcase
    end

        assign o_clear     = (current_state == CLEAR)  ? 1'b1 : 0;
        assign o_start     = (current_state == START)  ? 1'b1 : 0;
        assign o_inc_hour  = (current_state == HOUR )  ? 1'b1 : 0;
        assign o_inc_min   = (current_state == MIN  )  ? 1'b1 : 0;
        assign o_inc_sec   = (current_state == SEC  )  ? 1'b1 : 0;

    endmodule
 

    module watch_dp
    (
        input clk, rst,
        input start, clear, inc_sec, inc_min, inc_hour,

        output [6:0] msec,
        output [5:0] sec,
        output [5:0] min,
        output [4:0] hour
    );

        wire w_tick_100hz, w_tick_msec, w_tick_sec, w_tick_min;


    // hour tick counter
    w_tick_counter #(.TICK_COUNT(24),.WIDTH(5),.SETTIME(12)) U_HOUR
    (
        .clk        (clk),
        .rst        (rst),
        .i_tick     (w_tick_min),
        .clear      (clear),
        .inc_edge   (inc_hour),

        .o_time     (hour),
        .o_tick     ()
    );

    // min tick counter
    w_tick_counter #(.TICK_COUNT(60),.WIDTH(6),.SETTIME(0)) U_MIN
    (
        .clk        (clk),
        .rst        (rst),
        .i_tick     (w_tick_sec),
        .clear      (clear),
        .inc_edge   (inc_min),

        .o_time     (min),
        .o_tick     (w_tick_min)
    );

    // sec tick counter
    w_tick_counter #(.TICK_COUNT(60),.WIDTH(6),.SETTIME(0)) U_SEC
    (
        .clk        (clk),
        .rst        (rst),
        .i_tick     (w_tick_msec),
        .clear      (clear),
        .inc_edge   (inc_sec),

        .o_time     (sec),
        .o_tick     (w_tick_sec)
    );

    // msec tick counter
    w_tick_counter #(.TICK_COUNT(100),.WIDTH(7),.SETTIME(0)) U_MSEC
    (
        .clk        (clk),
        .rst        (rst),
        .i_tick     (w_tick_100hz),
        .clear      (clear),
        .inc_edge   (1'b0),

        .o_time     (msec),
        .o_tick     (w_tick_msec)
    );

    // generate 100hz tick
    w_tick_gen_100hz U_TICK_GEN
    (
        .clk        (clk),
        .rst        (rst),
        .start      (start),

        .o_tick     (w_tick_100hz)
    );
    endmodule


    module w_tick_counter
    #(
        parameter   TICK_COUNT = 100,
                    WIDTH = 7,               // msec (0~99) = Need 7bit
                    SETTIME = 0
    )
    (
        input               clk,
        input               rst,
        input               i_tick,
        input               clear,
        input               inc_edge,

        output [WIDTH-1:0]  o_time,
        output              o_tick
    );

        reg [$clog2(TICK_COUNT)-1:0] counter_reg, counter_next;
        reg                          tick_reg, tick_next;
        
        assign o_time = counter_reg;
        assign o_tick = tick_reg;

        always @(posedge clk, posedge rst) 
        begin
            if (rst)
            begin
                counter_reg <= SETTIME;
                tick_reg    <= 1'b0;
            end    
            
            else
            begin
                counter_reg <= counter_next;
                tick_reg    <= tick_next;
            end
        end


        always @(*) 
        begin

            counter_next = counter_reg;
            tick_next    = 1'b0;

            if(i_tick)                                  // if i_tick = 1 then counter inc
            begin
                if (counter_reg == TICK_COUNT - 1)
                begin
                    counter_next = 0;       
                    tick_next    = 1'b1;
                end

                else
                begin
                    counter_next = counter_reg + 1;
                    tick_next    = 1'b0;        
                end
            end

            if(clear) counter_next = 0;
            if(clear && SETTIME == 12) counter_next = SETTIME;   
            
            if(inc_edge)   
            begin
                if (counter_reg == TICK_COUNT - 1)
                begin
                    counter_next = 0;       
                end
                
                else
                begin
                    counter_next = counter_reg + 1;
                end
            end
        end
        
    endmodule


    module w_tick_gen_100hz
    (
        input clk,
        input rst,
        input start,

        output o_tick
    );

        parameter FCOUNT = 1_000_000 - 1;

        reg [$clog2(FCOUNT):0] counter;
        reg                    r_tick;

        assign o_tick = r_tick;

        always @(posedge clk, posedge rst) 
        begin
            if (rst)
            begin
                counter <= 0;
                r_tick <= 0;
            end    

            else
            begin
                if(start)
                begin
                    if(counter == FCOUNT)
                    begin
                        counter <= 0;
                        r_tick = 1'b1;
                    end
                    else
                    begin
                        counter <= counter + 1;
                        r_tick = 1'b0;
                    end
                end
            end
        end
    endmodule