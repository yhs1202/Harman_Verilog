`timescale 1ns / 1ps

module decoder_2x4(
    input       [1:0] sel,
    output reg [3:0] fnd_com
);
    
    always @(*) begin
         case(sel)
            2'b00:   fnd_com = 4'b1110;
            2'b01:   fnd_com = 4'b1101;
            2'b10:   fnd_com = 4'b1011;
            2'b11:   fnd_com = 4'b0111;
            default: fnd_com = 4'b1110;
        endcase
    end

endmodule
