`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/16 09:41:29
// Design Name: 
// Module Name: tb_bidir_bus
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


module tb_bidir_bus();
    reg send;
    reg [7:0] data_to_bus;
    reg rcv;
    wire [7:0] data_from_bus;
    wire [7:0] bus_data;

    bidir_bus uut (
        .send(send),
        .data_to_bus(data_to_bus),
        .rcv(rcv),
        .data_from_bus(data_from_bus),
        .bus_data(bus_data)
    );

    initial begin
        // Initialize signals
        send = 0;
        data_to_bus = 8'h00;
        rcv = 0;

        // Test sending data
        #10; send = 1; data_to_bus = 8'hA5; // Send A5
        #10; send = 0; // Stop sending

        // Test receiving data
        #10; rcv = 1; // Start receiving
        #10; rcv = 0; // Stop receiving

        // Check received data
        if (data_from_bus !== 8'hA5) begin
            $display("Error: Received data does not match sent data.");
        end else begin
            $display("Success: Received data matches sent data.");
        end

        $finish; // End simulation
    end
endmodule
