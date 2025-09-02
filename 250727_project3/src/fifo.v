`timescale 1ns / 1ps

module fifo (
    input       clk, rst,
    input [8:0] w_data,
    input       push, pop,

    output [8:0] r_data,
    output       full, empty
);

    wire [1:0] w_addr, r_addr;
    wire wt_en;

    register_file U_REGISTER_FILE (
        .clk   (clk),
        .w_data(w_data),
        .w_addr(w_addr),
        .r_addr(r_addr),
        .wt_en (~full & push), // NOT + AND gate

        .r_data(r_data)
    );

    fifo_control_unit U_FIFO_CU (
        .clk (clk),
        .rst (rst),
        .push(push),
        .pop (pop),

        .w_addr(w_addr),
        .r_addr(r_addr),
        .full  (full),
        .empty (empty)
    );

endmodule


module register_file (
    input       clk,
    input [8:0] w_data,
    input [1:0] w_addr,
    r_addr,
    input       wt_en,

    output [8:0] r_data
);
    reg [8:0] mem[0:3];

    // 조합논리 방식
    assign r_data = mem[r_addr];

    always @(posedge clk) begin
        if(wt_en)                   // write to mem
        begin
            mem[w_addr] <= w_data;
        end
    end
endmodule


module fifo_control_unit (
    input clk,
    rst,
    input push,
    pop,

    output [1:0] w_addr,
    r_addr,
    output       full,
    empty
);

    // 변수 선언
    reg [1:0] wptr_reg, wptr_next;
    reg [1:0] rptr_reg, rptr_next;
    reg full_reg, full_next;
    reg empty_reg, empty_next;

    // Output 연결
    assign w_addr = wptr_reg;
    assign r_addr = rptr_reg;
    assign full   = full_reg;
    assign empty  = empty_reg;

    // 초기화 및 현재값(reg) 갱신
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            wptr_reg  <= 0;
            rptr_reg  <= 0;
            full_reg  <= 1'b0;  // 초기
            empty_reg <= 1'b1;  // 상태
        end else begin
            wptr_reg  <= wptr_next;  // feedback 구조
            rptr_reg  <= rptr_next;
            full_reg  <= full_next;
            empty_reg <= empty_next;
        end
    end

    // 조합논리
    always @(*) begin
        wptr_next  = wptr_reg;
        rptr_next  = rptr_reg;
        full_next  = full_reg;
        empty_next = empty_reg;

        case ({
            push, pop
        })  // push, pop 결합

            2'b01 :                                 // pop 
                begin
                if (!empty_reg) begin
                    rptr_next = rptr_reg + 1;
                    full_next = 1'b0;

                    if(rptr_next == wptr_reg)    // 출력했더니 같아졌다? = empty
                        begin
                        empty_next = 1'b1;
                    end
                end
            end

            2'b10 :                                 // push
                begin
                if (!full_reg) begin
                    wptr_next  = wptr_reg + 1;
                    empty_next = 1'b0;

                    if (wptr_next == rptr_reg) begin
                        full_next = 1'b1;
                    end
                end
            end

            2'b11: begin
                if (empty_reg) begin
                    wptr_next  = wptr_reg + 1;
                    empty_next = 1'b0;
                end else if (full_reg) begin
                    rptr_next = rptr_reg + 1;
                    full_next = 1'b0;
                end else begin
                    wptr_next = wptr_reg + 1;
                    rptr_next = rptr_reg + 1;
                end
            end
        endcase
    end

endmodule
