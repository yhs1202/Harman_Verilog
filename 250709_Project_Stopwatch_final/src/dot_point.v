`timescale 1ns / 1ps

module dot_point(
    input [6:0] msec,
    output      dot_onoff
);

    assign dot_onoff = (msec >= 50) ?  1'b1: 1'b0;

endmodule
