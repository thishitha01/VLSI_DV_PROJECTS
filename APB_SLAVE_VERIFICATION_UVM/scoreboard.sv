class apb_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(apb_scoreboard)

  uvm_analysis_imp #(apb_transaction, apb_scoreboard) ap_imp;

  localparam int NUM_SLAVES = apb_transaction::NUM_SLAVES;
  localparam int ADDR_WIDTH = apb_transaction::ADDR_WIDTH;
  localparam int DATA_WIDTH = apb_transaction::DATA_WIDTH;
  localparam int OFF_WIDTH  = ADDR_WIDTH - $clog2(NUM_SLAVES);
  localparam int MEM_DEPTH  = apb_transaction::MEM_DEPTH;

  bit [DATA_WIDTH-1:0] ref_mem [NUM_SLAVES][MEM_DEPTH];

  int unsigned num_checked;
  int unsigned num_errors;
  int unsigned num_writes;
  int unsigned num_reads;
  int unsigned num_slverr_expected;

  function new(string name = "apb_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    ap_imp = new("ap_imp", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    foreach (ref_mem[s, a]) ref_mem[s][a] = 0;
  endfunction

  function void write(apb_transaction tr);
    bit [$clog2(NUM_SLAVES)-1:0] sel;
    bit [OFF_WIDTH-1:0]          off;
    bit                          addr_valid;

    sel        = tr.paddr[ADDR_WIDTH-1 -: $clog2(NUM_SLAVES)];
    off        = tr.paddr[OFF_WIDTH-1:0];
    addr_valid = (off < MEM_DEPTH);

    num_checked++;

    if (!addr_valid) begin
      num_slverr_expected++;
      if (!tr.pslverr) begin
        num_errors++;
        `uvm_error("APB_SB", $sformatf(
          "Expected PSLVERR for out-of-range addr 0x%0h but got pslverr=0", tr.paddr))
      end
      return;
    end

    if (tr.pslverr) begin
      num_errors++;
      `uvm_error("APB_SB", $sformatf(
        "Unexpected PSLVERR on valid addr 0x%0h", tr.paddr))
      return;
    end

    if (tr.pwrite) begin
      num_writes++;
      for (int b = 0; b < (DATA_WIDTH/8); b++) begin
        if (tr.pstrb[b])
          ref_mem[sel][off][b*8 +: 8] = tr.pwdata[b*8 +: 8];
      end
    end else begin
      num_reads++;
      if (tr.prdata !== ref_mem[sel][off]) begin
        num_errors++;
        `uvm_error("APB_SB", $sformatf(
          "READ MISMATCH slave=%0d addr=0x%0h exp=0x%0h act=0x%0h",
          sel, tr.paddr, ref_mem[sel][off], tr.prdata))
      end else begin
        `uvm_info("APB_SB", $sformatf(
          "READ MATCH slave=%0d addr=0x%0h data=0x%0h", sel, tr.paddr, tr.prdata), UVM_HIGH)
      end
    end
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info("APB_SB", $sformatf(
      "SCOREBOARD SUMMARY: checked=%0d writes=%0d reads=%0d slverr_expected=%0d errors=%0d",
      num_checked, num_writes, num_reads, num_slverr_expected, num_errors), UVM_LOW)
    if (num_errors == 0)
      `uvm_info("APB_SB", "*** TEST PASSED: no scoreboard mismatches ***", UVM_LOW)
    else
      `uvm_error("APB_SB", $sformatf("*** TEST FAILED: %0d mismatches ***", num_errors))
  endfunction

endclass
