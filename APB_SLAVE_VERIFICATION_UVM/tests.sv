class apb_base_test extends uvm_test;
  `uvm_component_utils(apb_base_test)
  apb_env env;

  function new(string name = "apb_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = apb_env::type_id::create("env", this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

  function void report_phase(uvm_phase phase);
    uvm_report_server svr;
    super.report_phase(phase);
    svr = uvm_report_server::get_server();
    if (svr.get_severity_count(UVM_FATAL) + svr.get_severity_count(UVM_ERROR) > 0)
      `uvm_info("APB_TEST", "*** OVERALL: FAIL (errors/fatals reported) ***", UVM_NONE)
    else
      `uvm_info("APB_TEST", "*** OVERALL: PASS ***", UVM_NONE)
  endfunction
endclass

class apb_smoke_test extends apb_base_test;
  `uvm_component_utils(apb_smoke_test)
  function new(string name = "apb_smoke_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_write_read_check_seq seq;
    phase.raise_objection(this);
    seq = apb_write_read_check_seq::type_id::create("seq");
    seq.start(env.agent.sqr);
    phase.drop_objection(this);
  endtask
endclass

class apb_random_test extends apb_base_test;
  `uvm_component_utils(apb_random_test)
  function new(string name = "apb_random_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_random_seq seq;
    phase.raise_objection(this);
    seq = apb_random_seq::type_id::create("seq");
    void'(seq.randomize() with { num_txns == 200; });
    seq.start(env.agent.sqr);
    phase.drop_objection(this);
  endtask
endclass

class apb_error_test extends apb_base_test;
  `uvm_component_utils(apb_error_test)
  function new(string name = "apb_error_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_error_seq seq;
    phase.raise_objection(this);
    seq = apb_error_seq::type_id::create("seq");
    void'(seq.randomize() with { num_txns == 20; });
    seq.start(env.agent.sqr);
    phase.drop_objection(this);
  endtask
endclass

class apb_full_test extends apb_base_test;
  `uvm_component_utils(apb_full_test)
  function new(string name = "apb_full_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_write_read_check_seq   smoke_seq;
    apb_back_to_back_seq       b2b_seq;
    apb_random_seq             rand_seq;
    apb_error_seq              err_seq;

    phase.raise_objection(this);

    smoke_seq = apb_write_read_check_seq::type_id::create("smoke_seq");
    smoke_seq.start(env.agent.sqr);

    for (int s = 0; s < apb_transaction::NUM_SLAVES; s++) begin
      b2b_seq = apb_back_to_back_seq::type_id::create("b2b_seq");
      void'(b2b_seq.randomize() with { num_txns == 15; target_slave == s; });
      b2b_seq.start(env.agent.sqr);
    end

    rand_seq = apb_random_seq::type_id::create("rand_seq");
    void'(rand_seq.randomize() with { num_txns == 300; });
    rand_seq.start(env.agent.sqr);

    err_seq = apb_error_seq::type_id::create("err_seq");
    void'(err_seq.randomize() with { num_txns == 20; });
    err_seq.start(env.agent.sqr);

    phase.drop_objection(this);
  endtask
endclass
