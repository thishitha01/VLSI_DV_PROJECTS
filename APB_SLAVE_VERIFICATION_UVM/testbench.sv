
`include "uvm_macros.svh"    // UVM macros
`include "package.sv"        // APB package

import uvm_pkg::*;           // Import UVM package
import pkg::*;               // Import user-defined package (APB environment)

module tb_top;
  localparam ADDR_WIDTH = 16;
  localparam DATA_WIDTH = 32;
  localparam NUM_SLAVES = 4;
  localparam MEM_DEPTH  = 256;

  bit pclk;
  bit presetn;

  initial pclk = 0;
  always #5 pclk = ~pclk;

  initial begin
    presetn = 0;
    #22 presetn = 1;
  end

  apb_if #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) vif (
    .pclk(pclk), .presetn(presetn)
  );

  apb_bridge_dut #(
    .ADDR_WIDTH (ADDR_WIDTH), .DATA_WIDTH (DATA_WIDTH),
    .NUM_SLAVES (NUM_SLAVES), .MEM_DEPTH  (MEM_DEPTH)
  ) dut (
    .pclk(vif.pclk), .presetn(vif.presetn),
    .paddr(vif.paddr), .psel(vif.psel), .penable(vif.penable),
    .pwrite(vif.pwrite), .pwdata(vif.pwdata), .pstrb(vif.pstrb),
    .prdata(vif.prdata), .pready(vif.pready), .pslverr(vif.pslverr)
  );

  initial begin
    uvm_config_db#(virtual apb_if.DRIVER)::set(null, "uvm_test_top.env.agent.drv", "vif", vif);
    uvm_config_db#(virtual apb_if.MONITOR)::set(null, "uvm_test_top.env.agent.mon", "vif", vif);
  end

  initial begin
    run_test("apb_smoke_test");
  end

  initial begin
    $dumpfile("apb_bridge.vcd");
    $dumpvars(0, tb_top);
  end

  initial begin
    #1_000_000;
    `uvm_fatal("TB_TOP", "Simulation timeout reached")
  end
endmodule
