`timescale 1ns / 1ps
module fnd_controller(
    input [8:0] sum,
    output [7:0] fnd_data
    );

    wire [3:0] w_digit_1;
    bcd_decoder U_BCD (
        .bcd(w_digit_1),
        .fnd_data(fnd_data)
    );

    digit_spliter U_DS (
    .sum (),
    .digit_1 (),
    .digit_10 (),
    .digit_100 (),
    .digit_1000 ()
    );

endmodule

module digit_spliter (
    input [8:0] sum,
    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0] digit_100,
    output [3:0] digit_1000
);

    assign digit_1 = sum % 10;
    assign digit_10 = sum/10 % 10;
    assign digit_100 = sum/100 % 10;
    assign digit_1000 = sum/1000 % 10;

endmodule

module bcd_decoder (
    input      [3:0] bcd,
    output reg [7:0] fnd_data
);

    always @(bcd) begin
        case (bcd)
            0: fnd_data = 8'hc0;
            1: fnd_data = 8'hf9;
            2: fnd_data = 8'ha4;
            3: fnd_data = 8'hb0;
            4: fnd_data = 8'h99;
            5: fnd_data = 8'h92;
            6: fnd_data = 8'h82;
            7: fnd_data = 8'hf8;
            8: fnd_data = 8'h80;
            9: fnd_data = 8'h90;
            default: fnd_data = 8'hff; 
        endcase
    end
endmodule