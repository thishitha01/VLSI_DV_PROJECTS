// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

module tb_synchronous_fifo;

  parameter WIDTH = 8;
  parameter DEPTH = 8;

  reg clk;
  reg rst;
  reg wr_en;
  reg rd_en;
  reg [WIDTH-1:0] data;
  wire [WIDTH-1:0] dout;
  wire full;
  wire empty;

  synchronous_fifo #(WIDTH, DEPTH) dut (
    .clk(clk),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .data(data),
    .dout(dout),
    .full(full),
    .empty(empty)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;  // 10ns clock period

  initial begin
    $display("------ Starting FIFO Test ------");
    rst = 1;
    wr_en = 0;
    rd_en = 0;
    data = 0;

    // Reset pulse
    #10 rst = 0;

    // WRITE 8 values into FIFO (fill it)
    for (int i = 0; i < DEPTH; i++) begin
      @(posedge clk);
      wr_en = 1;
      data = i;
    end

    @(posedge clk);
    wr_en = 0;  // Stop writing

    // READ 8 values from FIFO (empty it)
    for (int i = 0; i < DEPTH; i++) begin
      @(posedge clk);
      rd_en = 1;
    end

    @(posedge clk);
    rd_en = 0;  // Stop reading

    // Try reading when FIFO is empty
    repeat (2) @(posedge clk);

    // Try writing after FIFO is empty
    for (int i = 100; i < 104; i++) begin
      @(posedge clk);
      wr_en = 1;
      data = i;
    end

    wr_en = 0;

    // Read again
    repeat (4) begin
      @(posedge clk);
      rd_en = 1;
    end

    rd_en = 0;

    @(posedge clk);
    $display("FIFO Test Completed");
    $finish;
  end

endmodule
