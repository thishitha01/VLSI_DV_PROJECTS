class apb_base_seq extends uvm_sequence #(apb_transaction);
  `uvm_object_utils(apb_base_seq)
  function new(string name = "apb_base_seq");
    super.new(name);
  endfunction
endclass

class apb_random_seq extends apb_base_seq;
  `uvm_object_utils(apb_random_seq)
  rand int unsigned num_txns = 50; 

  function new(string name = "apb_random_seq");
    super.new(name);
  endfunction

  task body();
    apb_transaction tr;
    repeat (num_txns) begin
      tr = apb_transaction::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize())
        `uvm_error("APB_SEQ", "Randomization failed in apb_random_seq")
      finish_item(tr);
    end
  endtask
endclass

class apb_write_read_check_seq extends apb_base_seq;
  `uvm_object_utils(apb_write_read_check_seq)

  function new(string name = "apb_write_read_check_seq");
    super.new(name);
  endfunction

  task body();
    apb_transaction tr;
    for (int s = 0; s < apb_transaction::NUM_SLAVES; s++) begin
      tr = apb_transaction::type_id::create("tr_wr");
      start_item(tr);
      if (!tr.randomize() with {
            slave_id == s;
            force_invalid_addr == 0;
            pwrite == 1;
            pstrb == 4'b1111;
          })
        `uvm_error("APB_SEQ", "Randomization failed (write)")
      finish_item(tr);

      tr = apb_transaction::type_id::create("tr_rd");
      start_item(tr);
      if (!tr.randomize() with {
            slave_id == s;
            force_invalid_addr == 0;
            pwrite == 0;
          })
        `uvm_error("APB_SEQ", "Randomization failed (read)")
      finish_item(tr);
    end
  endtask
endclass

class apb_error_seq extends apb_base_seq;
  `uvm_object_utils(apb_error_seq)
  rand int unsigned num_txns = 10;

  function new(string name = "apb_error_seq");
    super.new(name);
  endfunction

  task body();
    apb_transaction tr;
    repeat (num_txns) begin
      tr = apb_transaction::type_id::create("tr_err");
      start_item(tr);
      if (!tr.randomize() with { force_invalid_addr == 1; })
        `uvm_error("APB_SEQ", "Randomization failed in apb_error_seq")
      finish_item(tr);
    end
  endtask
endclass

class apb_back_to_back_seq extends apb_base_seq;
  `uvm_object_utils(apb_back_to_back_seq)
  rand int unsigned num_txns = 20;
  rand bit [$clog2(apb_transaction::NUM_SLAVES)-1:0] target_slave;

  function new(string name = "apb_back_to_back_seq");
    super.new(name);
  endfunction

  task body();
    apb_transaction tr;
    repeat (num_txns) begin
      tr = apb_transaction::type_id::create("tr_b2b");
      start_item(tr);
      if (!tr.randomize() with {
            slave_id == target_slave;
            force_invalid_addr == 0;
          })
        `uvm_error("APB_SEQ", "Randomization failed in apb_back_to_back_seq")
      finish_item(tr);
    end
  endtask
endclass
