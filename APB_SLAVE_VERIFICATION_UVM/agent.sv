class apb_agent extends uvm_agent;
  `uvm_component_utils(apb_agent)

  apb_sequencer sqr;
  apb_driver    drv;
  apb_monitor   mon;

  uvm_active_passive_enum is_active = UVM_ACTIVE;
//uvm_active_passive_enum is an inbuilt UVM enum type. It is already defined in the UVM library, so you don't write its definition yourself.
  
  function new(string name = "apb_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon = apb_monitor::type_id::create("mon", this);
    if (is_active == UVM_ACTIVE) begin
      sqr = apb_sequencer::type_id::create("sqr", this);
      drv = apb_driver::type_id::create("drv", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (is_active == UVM_ACTIVE)
      drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction

endclass
