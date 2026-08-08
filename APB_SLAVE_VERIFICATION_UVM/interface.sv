`include "uvm_macros.svh"
import uvm_pkg::*;

interface apb_if #(
  parameter int ADDR_WIDTH = 16,
  parameter int DATA_WIDTH = 32
) (
  input logic pclk,
  input logic presetn
);

  logic [ADDR_WIDTH-1:0]      paddr;
  logic                       psel;
  logic                       penable;
  logic                       pwrite;
  logic [DATA_WIDTH-1:0]      pwdata;
  logic [(DATA_WIDTH/8)-1:0]  pstrb;
  logic [DATA_WIDTH-1:0]      prdata;
  logic                       pready;
  logic                       pslverr;

  clocking drv_cb @(posedge pclk);
    output paddr, psel, penable, pwrite, pwdata, pstrb;
    input  prdata, pready, pslverr;
  endclocking

  clocking mon_cb @(posedge pclk);
    input paddr, psel, penable, pwrite, pwdata, pstrb, prdata, pready, pslverr;
  endclocking

  modport DRIVER  (clocking drv_cb, input pclk, presetn);
  modport MONITOR (clocking mon_cb, input pclk, presetn);

  property p_setup_penable_low;
    @(posedge pclk) disable iff (!presetn)
    ($rose(psel)) |-> !penable;
  endproperty
  a_setup_penable_low: assert property (p_setup_penable_low)
    else $error("[APB_IF] PENABLE asserted in SETUP cycle (same cycle PSEL rose)");

  property p_setup_to_access;
    @(posedge pclk) disable iff (!presetn)
    (psel && !penable) |=> (psel |-> penable);
  endproperty
  a_setup_to_access: assert property (p_setup_to_access)
    else $error("[APB_IF] SETUP phase not followed by ACCESS (PENABLE) phase");

  property p_addr_stable_during_xfer;
    @(posedge pclk) disable iff (!presetn)
    (psel && penable && !pready) |=> $stable(paddr) && $stable(pwrite) && $stable(pwdata);
  endproperty
  a_addr_stable_during_xfer: assert property (p_addr_stable_during_xfer)
    else $error("[APB_IF] PADDR/PWRITE/PWDATA changed while transfer not yet ready");

  property p_psel_no_glitch;
    @(posedge pclk) disable iff (!presetn)
    (psel && !penable) |=> psel;
  endproperty
  a_psel_no_glitch: assert property (p_psel_no_glitch)
    else $error("[APB_IF] PSEL deasserted before completing SETUP+ACCESS");

  property p_reset_psel_low;
    @(posedge pclk) (!presetn) |-> !psel;
  endproperty
  a_reset_psel_low: assert property (p_reset_psel_low)
    else $error("[APB_IF] PSEL asserted during reset");

  cover property (@(posedge pclk) disable iff(!presetn) (psel && penable && pready && !pslverr));
  cover property (@(posedge pclk) disable iff(!presetn) (psel && penable && pslverr));

endinterface
