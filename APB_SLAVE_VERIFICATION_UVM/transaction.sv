class apb_transaction extends uvm_sequence_item;

  parameter int ADDR_WIDTH = 16;
  parameter int DATA_WIDTH = 32;
  parameter int NUM_SLAVES = 4;

  rand bit [ADDR_WIDTH-1:0]     paddr;
  rand bit                     pwrite;
  rand bit [DATA_WIDTH-1:0]    pwdata;
  rand bit [(DATA_WIDTH/8)-1:0] pstrb;

       bit [DATA_WIDTH-1:0]    prdata;
       bit                     pslverr;      

  rand bit [$clog2(NUM_SLAVES)-1:0] slave_id;
  rand bit                          force_invalid_addr;

  `uvm_object_utils_begin(apb_transaction)
    `uvm_field_int(paddr,   UVM_ALL_ON)
    `uvm_field_int(pwrite,  UVM_ALL_ON)
    `uvm_field_int(pwdata,  UVM_ALL_ON)
    `uvm_field_int(pstrb,   UVM_ALL_ON)
    `uvm_field_int(prdata,  UVM_ALL_ON)
    `uvm_field_int(pslverr, UVM_ALL_ON)
    `uvm_field_int(slave_id, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "apb_transaction");
    super.new(name);
  endfunction

  localparam int OFF_WIDTH = ADDR_WIDTH - $clog2(NUM_SLAVES);
  localparam int MEM_DEPTH = 256;

  constraint c_addr_in_range {
    if (!force_invalid_addr) {
      paddr[OFF_WIDTH-1:0] < MEM_DEPTH;
    } else {
      paddr[OFF_WIDTH-1:0] >= MEM_DEPTH;
    }
    paddr[ADDR_WIDTH-1 -: $clog2(NUM_SLAVES)] == slave_id;
  }

  constraint c_slave_dist {
    slave_id dist {[0:NUM_SLAVES-1] :/ 1};
  }

  constraint c_invalid_addr_rare {
    force_invalid_addr dist {0 :/ 90, 1 :/ 10};
  }

  constraint c_pstrb_realistic {
    pstrb dist { 4'b1111 :/ 70, 4'b0011 :/ 10, 4'b1100 :/ 10, 4'b0001 :/ 5, 4'b1000 :/ 5 };
  }

  constraint c_write_read_mix {
    pwrite dist {1 :/ 50, 0 :/ 50};
  }

  function string convert2string();
    return $sformatf(
      "paddr=0x%0h pwrite=%0b pwdata=0x%0h pstrb=%0b slave_id=%0d prdata=0x%0h pslverr=%0b",
      paddr, pwrite, pwdata, pstrb, slave_id, prdata, pslverr);
  endfunction

endclass
