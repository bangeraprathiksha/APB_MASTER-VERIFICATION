//======================================================
// Base Test
//======================================================
class apb_test extends uvm_test;
  `uvm_component_utils(apb_test)

  master_env env;
  master_base_seq base_seq;

  function new(string name="apb_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = master_env::type_id::create("env", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    base_seq = master_base_seq::type_id::create("base_seq");
    base_seq.start(env.act_agent.seqr);
    #30;
    phase.drop_objection(this);
  endtask
endclass

//======================================================
// Single Write Test
//======================================================
class single_write_test extends apb_test;
  `uvm_component_utils(single_write_test)

  function new(string name="single_write_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  task run_phase(uvm_phase phase);
    single_write_seq seq;
    phase.raise_objection(this);
    seq = single_write_seq::type_id::create("seq");
    seq.start(env.act_agent.seqr);
    #30;
    phase.drop_objection(this);
  endtask
endclass


//======================================================
// Single Read Test
//======================================================
class single_read_test extends apb_test;
  `uvm_component_utils(single_read_test)

  function new(string name="single_read_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  task run_phase(uvm_phase phase);
    single_read_seq seq;
    phase.raise_objection(this);
    seq = single_read_seq::type_id::create("seq");
    seq.start(env.act_agent.seqr);
    #30;
    phase.drop_objection(this);
  endtask
endclass


//======================================================
// Back to Back Transfer Test
//======================================================
class back_to_back_test extends apb_test;
  `uvm_component_utils(back_to_back_test)

  function new(string name="back_to_back_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  task run_phase(uvm_phase phase);
    back_to_back_seq seq;
    phase.raise_objection(this);
    seq = back_to_back_seq::type_id::create("seq");
    seq.start(env.act_agent.seqr);
    #30;
    phase.drop_objection(this);
  endtask
endclass


//======================================================
// Error Write Test
//======================================================
class error_write_test extends apb_test;
  `uvm_component_utils(error_write_test)

  function new(string name="error_write_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  task run_phase(uvm_phase phase);
    error_seq seq;
    phase.raise_objection(this);
    seq = error_seq::type_id::create("seq");
    seq.start(env.act_agent.seqr);
    #30;
    phase.drop_objection(this);
  endtask
endclass

//======================================================
// Regression Test
//======================================================
class regression_test extends apb_test;
  `uvm_component_utils(regression_test)

  regression_seq seq_reg;

  function new(string name="regression_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq_reg = regression_seq::type_id::create("seq_reg");
    seq_reg.start(env.act_agent.seqr);    // Runs all sequences one after another
    #50;
    phase.drop_objection(this);
  endtask
endclass
