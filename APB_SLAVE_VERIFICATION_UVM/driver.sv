class apb_driver extends uvm_driver #(apb_transaction);
  `uvm_component_utils(apb_driver)

  virtual apb_if.DRIVER vif;//it has only one interface but it says Give me access to the DRIVER modport of the interface.

  function new(string name = "apb_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if.DRIVER)::get(this, "", "vif", vif))
      //this means Start the search from me.
      //" " means Search for my own configuration."vif" is instance name
//The last argument is the variable that receives the value.-vif intially it is null now it points to apb interface 
      
    //  get() is usually done inside a component, so this tells UVM where in the hierarchy the search begins. Using "" means "use my current component's path." This allows the configuration mechanism to find the value intended for that component based on the hierarchy.

      `uvm_fatal("APB_DRV", "Virtual interface not set for driver")
  endfunction

  task run_phase(uvm_phase phase);
    vif.drv_cb.psel    <= 0;
    vif.drv_cb.penable <= 0;
    vif.drv_cb.paddr   <= '0;
    vif.drv_cb.pwrite  <= 0;
    vif.drv_cb.pwdata  <= '0;
    vif.drv_cb.pstrb   <= '0;

    wait (vif.presetn === 1'b1);

    forever begin
      apb_transaction tr;
      seq_item_port.get_next_item(tr);
      drive_transaction(tr);
      seq_item_port.item_done();
    end
  endtask

  task drive_transaction(apb_transaction tr);
    @(vif.drv_cb);
    vif.drv_cb.psel    <= 1'b1;
    vif.drv_cb.penable <= 1'b0;
    vif.drv_cb.paddr   <= tr.paddr;
    vif.drv_cb.pwrite  <= tr.pwrite;
    vif.drv_cb.pwdata  <= tr.pwdata;
    vif.drv_cb.pstrb   <= tr.pstrb;

    @(vif.drv_cb);
    vif.drv_cb.penable <= 1'b1;

    while (vif.drv_cb.pready !== 1'b1) begin
      @(vif.drv_cb);
    end

    tr.prdata  = vif.drv_cb.prdata;
    tr.pslverr = vif.drv_cb.pslverr;

    @(vif.drv_cb);
    vif.drv_cb.psel    <= 1'b0;
    vif.drv_cb.penable <= 1'b0;
  endtask

endclass
