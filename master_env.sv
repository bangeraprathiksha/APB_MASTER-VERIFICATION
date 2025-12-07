class master_env extends uvm_env;
  `uvm_component_utils(master_env)

  master_active_agent  act_agent;
  master_passive_agent pass_agent;
  master_scoreboard    sb;
  master_subscriber    subscriber;

  function new(string name = "master_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    act_agent  = master_active_agent ::type_id::create("act_agent",  this);
    pass_agent = master_passive_agent::type_id::create("pass_agent", this);
    sb         = master_scoreboard   ::type_id::create("sb",         this);
    subscriber = master_subscriber   ::type_id::create("subscriber", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

  act_agent.act_mon.mon_ap_act.connect(sb.act_imp);
  pass_agent.pass_mon.mon_ap_pass.connect(sb.exp_imp);

    act_agent.act_mon.mon_ap_act.connect(subscriber.act_mon_imp);
    pass_agent.pass_mon.mon_ap_pass.connect(subscriber.pass_mon_imp);

  endfunction

endclass
~
