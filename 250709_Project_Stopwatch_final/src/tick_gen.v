`timescale 1ns / 1ps

module tick_gen(
    input   clk,
    input   rst,    
    input   run_stop,
    input   clear,
    output  o_tick
);
    parameter FCOUNT = 1_000_000;
    reg [$clog2(FCOUNT)-1:0] counter;
    reg r_tick;

    assign o_tick = r_tick;

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            counter <= 0;
            r_tick  <= 0;
        end
        else begin
            if(run_stop) begin        
                if(counter == FCOUNT - 1) begin
                    counter <= 0;
                    r_tick <= 1'b1;
                end
                else begin
                    counter <= counter + 1;
                    r_tick <= 1'b0;
                end
            end
            else if (clear) begin
                counter <= 1'b0;
            end
        end
    end

endmodule
