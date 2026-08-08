class apb_coverage extends uvm_subscriber #(apb_transaction);
  `uvm_component_utils(apb_coverage)

  apb_transaction tr;
  bit prev_was_write;
  bit have_prev;

  covergroup cg_apb;
    option.per_instance = 1;
    cp_slave: coverpoint tr.slave_id {
      bins slave[] = {[0:apb_transaction::NUM_SLAVES-1]};
    }
    cp_rw: coverpoint tr.pwrite {
      bins write = {1};
      bins read  = {0};
    }
    cp_strb: coverpoint tr.pstrb {
      bins full_word  = {4'b1111};
      bins lower_half = {4'b0011};
      bins upper_half = {4'b1100};
      bins byte0      = {4'b0001};
      bins byte3      = {4'b1000};
      bins others     = default;
    }
    cp_err: coverpoint tr.pslverr {
      bins ok  = {0};
      bins err = {1};
    }
    cp_addr_edge: coverpoint tr.paddr[7:0] {
      bins low_edge  = {0};
      bins high_edge = {255};
      bins mid       = {[1:254]};
    }
    cx_slave_rw: cross cp_slave, cp_rw;
    cx_rw_err:   cross cp_rw, cp_err;
  endgroup

  covergroup cg_sequence;
    option.per_instance = 1;
    cp_back_to_back: coverpoint {prev_was_write, tr.pwrite} {
      bins write_then_write = {2'b11};
      bins write_then_read  = {2'b10};
      bins read_then_write  = {2'b01};
      bins read_then_read   = {2'b00};
    }
  endgroup

  function new(string name = "apb_coverage", uvm_component parent = null);
    super.new(name, parent);
    cg_apb = new();
    cg_sequence = new();
  endfunction

  function void write(apb_transaction t);
    tr = t;
    cg_apb.sample();
    if (have_prev) cg_sequence.sample();
    prev_was_write = tr.pwrite;
    have_prev = 1;
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info("APB_COV", $sformatf(
      "Functional coverage: cg_apb=%0.2f%% cg_sequence=%0.2f%%",
      cg_apb.get_coverage(), cg_sequence.get_coverage()), UVM_LOW)
  endfunction

endclass
