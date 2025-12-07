class master_active_agent extends uvm_agent;
  `uvm_component_utils(master_active_agent)

  master_sequencer        seqr;
  master_driver           driv;
  master_active_monitor   act_mon;

  function new(string name = "master_active_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    seqr = master_sequencer::type_id::create("seqr", this);
    driv = master_driver::type_id::create("driv", this);
    act_mon = master_active_monitor::type_id::create("act_mon", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    driv.seq_item_port.connect(seqr.seq_item_export);
  endfunction

endclass

class master_passive_agent extends uvm_agent;
  `uvm_component_utils(master_passive_agent)

  master_passive_monitor pass_mon;

  function new(string name = "master_passive_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    pass_mon = master_passive_monitor::type_id::create("pass_mon", this);
  endfunction

endclass
