`timescale 1ns/1ps

module alu_8bit_pipelined (
    input  logic        clk, rst,
    input  logic [7:0]  A, B,
    input  logic [2:0]  opcode,
    input  logic        signed_op,
    output logic [7:0]  result,
    output logic        carry, overflow, zero, negative
);

    // Pipeline registers
    logic [7:0]  A_reg, B_reg, result_reg;
    logic [2:0]  opcode_reg;
    logic        signed_op_reg;
    logic        carry_reg, overflow_reg, zero_reg, negative_reg;

    // Intermediate results
    logic [8:0] add_sub_res;
    logic [7:0] logic_res, shift_res;

    // Stage 1: Register inputs
always @(posedge clk or posedge rst) begin
    if (rst) begin
        A_reg <= 0; B_reg <= 0;
        opcode_reg <= 0; signed_op_reg <= 0;
    end else begin
        A_reg <= A;
        B_reg <= B;
        opcode_reg <= opcode;
        signed_op_reg <= signed_op;
    end
end

// Stage 2 + 3: Compute results and flags
always @(A_reg or B_reg or opcode_reg or signed_op_reg) begin
    // Arithmetic
    if (opcode_reg==3'b000) begin
        if (signed_op_reg)
            add_sub_res = $signed(A_reg) + $signed(B_reg);
        else
            add_sub_res = {1'b0, A_reg} + {1'b0, B_reg};
    end else if (opcode_reg==3'b001) begin
        if (signed_op_reg)
            add_sub_res = $signed(A_reg) - $signed(B_reg);
        else
            add_sub_res = {1'b0, A_reg} - {1'b0, B_reg};
    end else add_sub_res = 9'd0;

    // Logic
    case(opcode_reg)
        3'b010: logic_res = A_reg & B_reg;
        3'b011: logic_res = A_reg | B_reg;
        3'b100: logic_res = A_reg ^ B_reg;
        3'b101: logic_res = ~A_reg;
        default: logic_res = 8'd0;
    endcase

    // Shift
    case(opcode_reg)
        3'b110: shift_res = A_reg << 1;
        3'b111: shift_res = A_reg >> 1;
        default: shift_res = 8'd0;
    endcase

    // Result & flags
    case(opcode_reg)
        3'b000,3'b001: begin
            result_reg = add_sub_res[7:0];
            // Carry
            if (!signed_op_reg) begin
                if (opcode_reg==3'b000) carry_reg = add_sub_res[8];
                else carry_reg = (A_reg < B_reg);
            end else carry_reg = 1'b0;

            // Overflow for signed
            if (signed_op_reg) begin
                if (opcode_reg==3'b000)
                    overflow_reg = (A_reg[7]==B_reg[7]) && (result_reg[7]!=A_reg[7]);
                else
                    overflow_reg = (A_reg[7]!=B_reg[7]) && (result_reg[7]!=A_reg[7]);
            end else overflow_reg = 1'b0;
        end
        3'b010,3'b011,3'b100,3'b101: begin
            result_reg = logic_res;
            carry_reg = 1'b0;
            overflow_reg = 1'b0;
        end
        3'b110,3'b111: begin
            result_reg = shift_res;
            carry_reg = (opcode_reg==3'b110)? A_reg[7] : A_reg[0];
            overflow_reg = 1'b0;
        end
    endcase

    zero_reg = (result_reg==8'd0);
    negative_reg = result_reg[7];
end


    assign result   = result_reg;
    assign carry    = carry_reg;
    assign overflow = overflow_reg;
    assign zero     = zero_reg;
    assign negative = negative_reg;

endmodule
