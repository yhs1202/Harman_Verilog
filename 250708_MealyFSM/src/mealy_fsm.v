`timescale 1ns / 1ps
module mealy_fsm(
    input clk, rst, din_bit,
    output dout_bit
    );

    reg [2:0] state_reg, next_state;

    parameter START = 3'b000;
    parameter RD0_Once= 3'b001;
    parameter RD1_Once = 3'b010;
    parameter RD0_Twice= 3'b011;
    parameter RD1_Twice = 3'b100;
    
    always @(state_reg or din_bit) begin
        case (state_reg)
            START: if (din_bit == 0) next_state = RD0_Once;
            else if (din_bit == 1) next_state = RD1_Once;
            else next_state = START;
            
            RD0_Once: if (din_bit == 0) next_state = RD0_Twice;
            else if (din_bit == 1) next_state = RD1_Once;
            else next_state = START;

            RD0_Twice: if (din_bit == 0) next_state = RD0_Twice;
            else if (din_bit == 1) next_state = RD1_Once;
            else next_state = START;

            RD1_Once: if (din_bit == 0) next_state = RD0_Once;
            else if (din_bit == 1) next_state = RD1_Twice;
            else next_state = START;

            RD1_Twice: if (din_bit == 0) next_state = RD0_Once;
            else if (din_bit == 1) next_state = RD1_Twice;
            else next_state = START;
            default: next_state = START;
        endcase
    end

    always @(posedge clk, posedge rst) begin
        if(rst) state_reg <= START;
        else state_reg <= next_state;
    end

    assign dout_bit =(((state_reg == RD0_Twice) && (din_bit == 0) ||
                        (state_reg == RD1_Twice) && (din_bit == 1))) ? 1 : 0;
endmodule
