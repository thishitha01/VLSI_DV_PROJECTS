class apb_monitor extends uvm_monitor;
  `uvm_component_utils(apb_monitor)

  virtual apb_if.MONITOR vif;
  uvm_analysis_port #(apb_transaction) ap;

  function new(string name = "apb_monitor", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if.MONITOR)::get(this, "", "vif", vif))
      `uvm_fatal("APB_MON", "Virtual interface not set for monitor")
  endfunction

  task run_phase(uvm_phase phase);
    wait (vif.presetn === 1'b1);
    forever begin
      @(vif.mon_cb);
      if (vif.mon_cb.psel && vif.mon_cb.penable && vif.mon_cb.pready) begin
        apb_transaction tr = apb_transaction::type_id::create("tr");
        tr.paddr    = vif.mon_cb.paddr;
        tr.pwrite   = vif.mon_cb.pwrite;
        tr.pwdata   = vif.mon_cb.pwdata;
        tr.pstrb    = vif.mon_cb.pstrb;
        tr.prdata   = vif.mon_cb.prdata;
        tr.pslverr  = vif.mon_cb.pslverr;
        tr.slave_id = tr.paddr[apb_transaction::ADDR_WIDTH-1 -: $clog2(apb_transaction::NUM_SLAVES)];

        `uvm_info("APB_MON", $sformatf("Observed: %s", tr.convert2string()), UVM_HIGH)
        ap.write(tr);
      end
    end
  endtask

endclass
