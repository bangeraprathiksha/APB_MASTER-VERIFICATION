class master_driver extends uvm_driver #(master_seq_item);
  `uvm_component_utils(master_driver)
  virtual master_interface vif;

  function new(string name="master_driver", uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual master_interface)::get(this,"","vif",vif))
      `uvm_fatal("DRV","No VIF")
  endfunction

  task run_phase(uvm_phase phase);
    master_seq_item req;
   @(vif.drv_cb);
   forever begin
      seq_item_port.get_next_item(req);
      drive(req);
      seq_item_port.item_done();
    end
  endtask
task drive(master_seq_item req);

  // drive request
  vif.presetn    <= req.presetn;
  vif.transfer   <= req.transfer;
  vif.write_read <= req.write_read;
  vif.addr_in    <= req.addr_in;
  vif.wdata_in   <= req.wdata_in;
  vif.strb_in    <= req.strb_in;

  // default slave output values (important to avoid X)
  vif.prdata  <= $urandom();
  vif.pslverr <= $urandom_range(0,1);

  // SETUP
  vif.pready <= 0;
  @(vif.drv_cb);
  `uvm_info("DRV_SETUP",
    $sformatf("presetn=%0b transfer=%0b write_read=%0b addr=%0h wd=%0h pready=%0b prdata=%0h pslverr=%0b",
              vif.presetn, vif.transfer, vif.write_read, vif.addr_in,
              vif.wdata_in, vif.pready, vif.prdata, vif.pslverr), UVM_LOW)

  // ACCESS with wait states
  repeat($urandom_range(1,4)) @(vif.drv_cb);

  vif.pready <= 1;
  @(vif.drv_cb);
  `uvm_info("DRV_ACCESS",
    $sformatf("presetn=%0b transfer=%0b write_read=%0b addr=%0h wd=%0h pready=%0b prdata=%0h pslverr=%0b",
              vif.presetn, vif.transfer, vif.write_read, vif.addr_in,
              vif.wdata_in, vif.pready, vif.prdata, vif.pslverr), UVM_LOW)
    @(vif.drv_cb);
    vif.transfer   <= 0;
    vif.write_read <= 0;
    vif.addr_in    <= '0;
    vif.wdata_in   <= '0;
    vif.strb_in    <= 0;
    vif.pready     <= 0;
    `uvm_info("DRV_IDLE","No transfer remaining in IDLE",UVM_LOW)
endtask


endclass
