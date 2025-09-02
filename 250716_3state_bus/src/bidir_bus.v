`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/16 09:39:46
// Design Name: 
// Module Name: bidir_bus
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bidir_bus(
    input send,
    input [7:0] data_to_bus,
    input rcv,
    output [7:0] data_from_bus,
    inout [7:0] bus_data
    );

    assign bus_data = (send) ? data_to_bus : 8'bzz; // send data to bus when send is high
    assign data_from_bus = (rcv) ? bus_data : 8'bzz;

endmodule
