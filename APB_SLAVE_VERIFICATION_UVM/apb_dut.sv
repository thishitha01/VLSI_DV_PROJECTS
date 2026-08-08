module apb_bridge_dut #(
  parameter int ADDR_WIDTH  = 16,
  parameter int DATA_WIDTH  = 32,
  parameter int NUM_SLAVES  = 4,
  parameter int MEM_DEPTH   = 256
)(
  input  logic                      pclk,
  input  logic                      presetn,
  input  logic [ADDR_WIDTH-1:0]     paddr,
  input  logic                      psel,
  input  logic                      penable,
  input  logic                      pwrite,
  input  logic [DATA_WIDTH-1:0]     pwdata,
  input  logic [(DATA_WIDTH/8)-1:0] pstrb,
  output logic [DATA_WIDTH-1:0]     prdata,
  output logic                      pready,
  output logic                      pslverr
);
  localparam int SEL_WIDTH = $clog2(NUM_SLAVES);
  localparam int OFF_WIDTH = ADDR_WIDTH - SEL_WIDTH;
  logic [DATA_WIDTH-1:0] mem [NUM_SLAVES][MEM_DEPTH];
  logic [SEL_WIDTH-1:0] slave_sel;
  logic [OFF_WIDTH-1:0] offset;
  logic                 addr_valid;
  logic                 access_phase;

  assign slave_sel    = paddr[ADDR_WIDTH-1 -: SEL_WIDTH];
  assign offset       = paddr[OFF_WIDTH-1:0];
  assign addr_valid   = (offset < MEM_DEPTH);
  assign access_phase = psel & penable;
  assign pready  = access_phase;
  assign pslverr = access_phase & ~addr_valid;
  assign prdata  = (access_phase & addr_valid & ~pwrite) ? mem[slave_sel][offset] : '0;

  always_ff @(posedge pclk) begin
    if (!presetn) begin
      for (int s = 0; s < NUM_SLAVES; s++)
        for (int a = 0; a < MEM_DEPTH; a++)
          mem[s][a] <= '0;
    end
    else if (access_phase && pwrite && addr_valid) begin
      for (int b = 0; b < (DATA_WIDTH/8); b++) begin
        if (pstrb[b])
          mem[slave_sel][offset][b*8 +: 8] <= pwdata[b*8 +: 8];
      end
    end
  end
endmodule
