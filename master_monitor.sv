class master_active_monitor extends uvm_monitor;
  `uvm_component_utils(master_active_monitor)

  virtual master_interface vif;
  uvm_analysis_port #(master_seq_item) mon_ap_act;

  function new(string name = "master_active_monitor", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual master_interface)::get(this, "", "vif", vif))
      `uvm_error(get_full_name(), "Failed to get interface")

    mon_ap_act = new("mon_ap_act", this);
  endfunction


  task run_phase(uvm_phase phase);
    master_seq_item req;
    @(vif.mon_act_cb);
    forever begin
      req = master_seq_item::type_id::create("req");
      input_capture(req);
    end
  endtask


  task input_capture(master_seq_item req);

    req.presetn     = vif.presetn;
    req.transfer    = vif.transfer;
    req.write_read  = vif.write_read;
    req.addr_in     = vif.addr_in;
    req.wdata_in    = vif.wdata_in;
    req.strb_in     = vif.strb_in;
    req.pready      = vif.pready;
    req.prdata      = vif.prdata;
    req.pslverr     = vif.pslverr;
`uvm_info("ACTIVE_MON",
  $sformatf("presetn=%0d transfer=%0d write_read=%0d addr=%0h wdata=%0h strb=%0d pready=%0d prdata=%0h pslverr=%0d\n",
            req.presetn, req.transfer, req.write_read,
            req.addr_in, req.wdata_in, req.strb_in,
            req.pready, req.prdata, req.pslverr),
  UVM_MEDIUM)
        mon_ap_act.write(req);
        @(vif.mon_act_cb);
  endtask

endclass

class master_passive_monitor extends uvm_monitor;
  `uvm_component_utils(master_passive_monitor)

  virtual master_interface vif;
  uvm_analysis_port #(master_seq_item) mon_ap_pass;

  function new(string name = "master_passive_monitor", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual master_interface)::get(this, "", "vif", vif))
      `uvm_error(get_full_name(), "Failed to get interface")

    mon_ap_pass = new("mon_ap_pass", this);
  endfunction


task run_phase(uvm_phase phase);
    master_seq_item req;
        repeat(1)@(vif.mon_pass_cb);
    forever begin
        // SAMPLE ON THE SAME CLOCK AS DUT

        // create transaction
        req = master_seq_item::type_id::create("req");

        req.paddr         = vif.paddr;
        req.psel          = vif.psel;
        req.penable       = vif.penable;
        req.pwrite        = vif.pwrite;
        req.pwdata        = vif.pwdata;
        req.pstrb         = vif.pstrb;
        req.prdata        = vif.prdata;
        req.pready        = vif.pready;
        req.error         = vif.error;
        req.transfer_done = vif.transfer_done;
        req.rdata_out     = vif.rdata_out;

        // SEND ONLY WHEN VALID OR pready CHANGE
        if (vif.psel && vif.penable )begin
        `uvm_info("PASSIVE_MON", $sformatf("paddr=%0h psel=%0d penable=%0d pwrite=%0d pready=%0d",req.paddr, req.psel, req.penable, req.pwrite, req.pready), UVM_MEDIUM)

            mon_ap_pass.write(req);
        end

        @(vif.mon_pass_cb);
    end
endtask

endclass
