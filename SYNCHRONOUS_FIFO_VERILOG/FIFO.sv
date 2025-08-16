module synchronous_fifo #(parameter WIDTH=8, DEPTH=8)(
  input rst,
  input clk,
  input wr_en,
  input rd_en,
  input [WIDTH-1:0] data,
  output reg [WIDTH-1:0] dout,
  output full,
  output empty
);

  // Internal write and read pointers
  reg [$clog2(DEPTH)-1:0] wr_ptr;
  reg [$clog2(DEPTH)-1:0] rd_ptr;

  // FIFO memory array
  reg [WIDTH-1:0] fifo [0:DEPTH-1];

  // Full and Empty conditions (circular buffer logic)
  assign full  = ((wr_ptr + 1) % DEPTH) == rd_ptr;
  assign empty = (wr_ptr == rd_ptr);

  // WRITE logic
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      wr_ptr <= 0;
    end else if (wr_en && !full) begin
      fifo[wr_ptr] <= data;
      wr_ptr <= wr_ptr + 1;
    end
  end

  // READ logic
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      rd_ptr <= 0;
      dout <= 0;
    end else if (rd_en && !empty) begin
      dout <= fifo[rd_ptr];
      rd_ptr <= rd_ptr + 1;
    end
  end

  initial begin
    $monitor("Time=%0t | wr_en=%0b, data=0x%0h | rd_en=%0b, dout=0x%0h | empty=%0b, full=%0b",$time, wr_en, data, rd_en, dout, empty, full);
  end

endmodule
