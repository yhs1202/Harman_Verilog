`timescale 1ns / 1ps
module RAM_IP(
    input clk,
    input [7:0] addr,
    input [7:0] wr_data,
    input write_en,
    output [7:0] rd_data
    );
    // addr -> 10bit, wr_data -> 8bit
    reg [7:0] ram [0:1023]; // 1024 x 8-bit memory
    reg [7:0] rd_data_reg; // Register for read data
    assign rd_data = rd_data_reg; // Output read data
    
    
    // CL output logic
    // assign rd_data = ram[addr]; // Read data from RAM

    // always @(posedge clk) begin // no reset
    //     if (write_en) begin
    //         ram[addr] = wr_data; // Write data to RAM
    //     end
    // end

    // SL output logic
    always @(posedge clk) begin
        if (write_en) begin
            ram[addr] <= wr_data; // Write data to RAM
        end else begin
            rd_data_reg <= ram[addr]; // Read data from RAM
        end
    end
endmodule
