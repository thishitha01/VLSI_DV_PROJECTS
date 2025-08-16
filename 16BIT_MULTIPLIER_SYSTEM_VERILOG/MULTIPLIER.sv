// Code your design here
module multiplier(
  input wire clk,
  input wire rst_n,
  input wire [15:0]a,
  input wire [15:0]b,
  output reg [31:0] res);
  
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      res<=0;
    end
    else begin
      res<=a*b;
    end
  end
endmodule


  
  
