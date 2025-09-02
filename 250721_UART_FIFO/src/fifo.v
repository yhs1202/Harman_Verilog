`timescale 1ns / 1ps
module fifo(
    input clk,
    input rst,
    input [7:0] w_data,
    input push,
    input pop,

    output full,
    output empty,
    output [7:0] r_data
    );

    wire [1:0] w_addr, r_addr;
    register_file U_REG_FILE (
        .clk(clk),
        .w_data(w_data),
        .w_addr(w_addr),
        .r_addr(r_addr),
        .write_en(push & ~full),
        .r_data(r_data)
    );

    fifo_control_unit U_FIFO_CU (
        .clk(clk),
        .rst(rst),
        .push(push),
        .pop(pop),
        .r_addr(r_addr),
        .w_addr(w_addr),
        .full(full),
        .empty(empty)
    );

endmodule


module register_file (
    input clk,
    input [7:0] w_data,
    input [1:0] w_addr,
    input [1:0] r_addr,
    input write_en,

    output [7:0] r_data

);
    reg [7:0] mem[0:3]; // 4 addresses, 8-bit data each

    // read data (CL)
    assign r_data = mem[r_addr];

    always @(posedge clk) begin
        if (write_en) begin
            // write data
            mem[w_addr] <= w_data;
        end 
    end
endmodule

module fifo_control_unit (
    input clk,
    input rst,
    input push,
    input pop,

    output [1:0] r_addr,
    output [1:0] w_addr,
    output full,
    output empty
);

    // FIFO control logic (FSM)

    // address pointers
    reg [1:0] w_ptr_reg, w_ptr_next;
    reg [1:0] r_ptr_reg, r_ptr_next;
    reg full_reg, full_next;
    reg empty_reg, empty_next;

    // output
    assign w_addr = w_ptr_reg;
    assign r_addr = r_ptr_reg;
    assign full = full_reg;
    assign empty = empty_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            w_ptr_reg <= 0;
            r_ptr_reg <= 0;
            full_reg <= 0;
            empty_reg <= 1;
        end else begin
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
            full_reg <= full_next;
            empty_reg <= empty_next;
        end
    end

    always @(*) begin
        w_ptr_next = w_ptr_reg;
        r_ptr_next = r_ptr_reg;
        full_next = full_reg;
        empty_next = empty_reg;

        case ({push, pop})
            2'b01: begin // pop operation
                if (!empty_reg) begin
                    r_ptr_next = r_ptr_reg + 1;
                    full_next = 0;
                    if (r_ptr_next == w_ptr_reg) begin
                        empty_next = 1;
                    end
                end
            end

            2'b10: begin // push operation
                if (!full_reg) begin
                    w_ptr_next = w_ptr_reg + 1;
                    empty_next = 1'b0;
                    if (w_ptr_next == r_ptr_reg) begin
                        full_next = 1;
                    end
                end
            end

            2'b11: begin // push, pop -> 
            // empty -> only push operation
            if (empty_reg) begin
                w_ptr_next = w_ptr_reg + 1;
                empty_next = 1'b0;
            // full -> only pop operation?
            end else if (full_reg) begin
               r_ptr_next = r_ptr_reg + 1;
               full_next = 1'b0;
            end else begin //
                w_ptr_next = w_ptr_reg + 1;
                r_ptr_next = r_ptr_reg + 1;
                end
            end
        endcase
    end
    
endmodule