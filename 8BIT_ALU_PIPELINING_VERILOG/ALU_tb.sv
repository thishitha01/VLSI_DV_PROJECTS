`timescale 1ns/1ps

module tb_alu_8bit_pipelined;

    logic clk, rst;
    logic [7:0] A, B;
    logic [2:0] opcode;
    logic signed_op;
    logic [7:0] result;
    logic carry, overflow, zero, negative;

    // Instantiate the ALU
    alu_8bit_pipelined uut (
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .opcode(opcode),
        .signed_op(signed_op),
        .result(result),
        .carry(carry),
        .overflow(overflow),
        .zero(zero),
        .negative(negative)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst = 1; #10; rst = 0;

        // Example test vectors
        A = 8'd10; B = 8'd20; opcode = 3'b000; signed_op = 0; #50;
        A = 8'd50; B = 8'd70; opcode = 3'b000; signed_op = 0; #50;
        A = 8'd127; B = 8'd1; opcode = 3'b000; signed_op = 1; #50;
        A = 8'd5; B = 8'd10; opcode = 3'b001; signed_op = 0; #50;
        A = 8'd0; B = 8'd1; opcode = 3'b001; signed_op = 1; #50;
        A = 8'b10101010; B = 8'b11001100; opcode = 3'b010; signed_op = 0; #50;
        opcode = 3'b011; #50;
        opcode = 3'b100; #50;
        opcode = 3'b101; #50;
        A = 8'b10010110; opcode = 3'b110; #50;
        opcode = 3'b111; #50;

        #20; $finish;
    end

    // Monitor outputs
    initial begin
        $display("Time | A B opcode signed | result carry overflow zero negative");
        $monitor("%0t | A=%b B=%b opcode=%b signed=%b | result=%b carry=%b overflow=%b zero=%b negative=%b",
                 $time, A, B, opcode, signed_op, result, carry, overflow, zero, negative);
    end

endmodule
