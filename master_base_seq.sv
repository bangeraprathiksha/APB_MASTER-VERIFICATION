// ============================================================================
// BASE SEQUENCE
// ============================================================================
class master_base_seq extends uvm_sequence #(master_seq_item);
  `uvm_object_utils(master_base_seq)

  master_seq_item req;

  function new(string name = "master_base_seq");
    super.new(name);
  endfunction

  virtual task body();
    req = master_seq_item::type_id::create("req");
    for(int i=0; i<`no_of_trans; i++) begin
      start_item(req);
      assert(req.randomize()with{ req.transfer == 1;});
      finish_item(req);
      `uvm_info("BASE_SEQ",$sformatf("Random Transaction: transfer=%0d wr=%0d addr=%0h wdata=%0h",
      req.transfer,req.write_read,req.addr_in,req.wdata_in),UVM_LOW)
    end
  endtask
endclass

// ============================================================================
// TEST SEQUENCES
// ============================================================================

class master_sequence_pready2 extends master_base_seq;
  `uvm_object_utils(master_sequence_pready2)
  function new(string name="master_sequence_pready2"); super.new(name); endfunction

  virtual task body();
    repeat(5) begin
      req = master_seq_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with { presetn==1; transfer==1; });
      finish_item(req);
      `uvm_info("SEQ_PREADY2","Transaction with transfer=1",UVM_LOW)
    end
  endtask
endclass


class single_write_seq extends master_base_seq;
  `uvm_object_utils(single_write_seq)

  virtual task body();
    req = master_seq_item::type_id::create("req");
    req.transfer=1; req.write_read=1;
    req.addr_in=8'h5F; req.wdata_in=32'h1D60BD22; req.strb_in=4'hF;
    start_item(req); finish_item(req);
    `uvm_info("SEQ","Single Write Test Executed",UVM_LOW)
  endtask
endclass


class single_read_seq extends master_base_seq;
  `uvm_object_utils(single_read_seq)

  virtual task body();
    req = master_seq_item::type_id::create("req");
    req.transfer=1; req.write_read=0; req.addr_in=8'h5F;
    start_item(req); finish_item(req);
    `uvm_info("SEQ","Single Read Test Executed",UVM_LOW)
  endtask
endclass


class back_to_back_seq extends master_base_seq;
  `uvm_object_utils(back_to_back_seq)
  virtual task body();
    repeat(5) begin
      req=master_seq_item::type_id::create("req"); req.transfer=1;
      req.randomize();
      start_item(req); finish_item(req);
    end
    `uvm_info("SEQ","Back-to-Back Transactions Done",UVM_LOW)
  endtask
endclass


class random_access_seq extends master_base_seq;
  `uvm_object_utils(random_access_seq)
  virtual task body();
    repeat(10) begin
      req=master_seq_item::type_id::create("req");
      assert(req.randomize() with { transfer==1; addr_in inside {[0:255]}; });
      start_item(req); finish_item(req);
    end
    `uvm_info("SEQ","Random Access Test",UVM_LOW)
  endtask
endclass


class error_seq extends master_base_seq;
  `uvm_object_utils(error_seq)
  virtual task body();
    req=master_seq_item::type_id::create("req");
    req.transfer=1; req.write_read=1; req.pslverr=1;
    start_item(req); finish_item(req);
    `uvm_info("SEQ","Error Handling Test",UVM_LOW)
  endtask
endclass


class immediate_ready_seq extends master_base_seq;
  `uvm_object_utils(immediate_ready_seq)
  virtual task body();
    req=master_seq_item::type_id::create("req");
    req.transfer=1; req.pready=1;
    start_item(req); finish_item(req);
    `uvm_info("SEQ","Immediate PREADY Test",UVM_LOW)
  endtask
endclass


class delayed_ready_seq extends master_base_seq;
  `uvm_object_utils(delayed_ready_seq)
  virtual task body();
    req=master_seq_item::type_id::create("req"); req.transfer=1; req.pready=0;
    start_item(req); finish_item(req);
    #10;
    `uvm_info("SEQ","Delayed PREADY Test",UVM_LOW)
  endtask
endclass


class reset_seq extends master_base_seq;
  `uvm_object_utils(reset_seq)
  virtual task body();
    req=master_seq_item::type_id::create("req"); req.presetn=0;
    start_item(req); finish_item(req);
    `uvm_info("SEQ","Reset Test executed",UVM_LOW)
  endtask
endclass


class timing_seq extends master_base_seq;
  `uvm_object_utils(timing_seq)
  virtual task body();
    req=master_seq_item::type_id::create("req"); req.transfer=1;
    start_item(req); finish_item(req);
    `uvm_info("SEQ","Timing Test",UVM_LOW)
  endtask
endclass


class transfer_during_access_seq extends master_base_seq;
  `uvm_object_utils(transfer_during_access_seq)
  virtual task body();
    req=master_seq_item::type_id::create("req"); req.transfer=1;
    start_item(req); finish_item(req);
    req=master_seq_item::type_id::create("req"); req.transfer=1;
    start_item(req); finish_item(req);
    `uvm_info("SEQ","Transfer during ACCESS Test",UVM_LOW)
  endtask
endclass


class pstrb_zero_seq extends master_base_seq;
  `uvm_object_utils(pstrb_zero_seq)
  virtual task body();
    req=master_seq_item::type_id::create("req");
    req.transfer=1; req.write_read=1; req.strb_in=0;
    start_item(req); finish_item(req);
    `uvm_info("SEQ","PSTRB=0 Test",UVM_LOW)
  endtask
endclass


class read_invalid_seq extends master_base_seq;
  `uvm_object_utils(read_invalid_seq)
  virtual task body();
    req=master_seq_item::type_id::create("req");
    req.transfer=1; req.write_read=0; req.prdata=0;
    start_item(req); finish_item(req);
    `uvm_info("SEQ","Read Invalid Data Test",UVM_LOW)
  endtask
endclass


// ============================================================================
// REGRESSION SEQUENCE �~@~S Runs All Tests
// ============================================================================
class regression_seq extends uvm_sequence #(master_seq_item);
  `uvm_object_utils(regression_seq)

virtual task body();
  single_write_seq seq1;
  single_read_seq seq2;
  back_to_back_seq seq3;
  random_access_seq seq4;
  error_seq seq5;
  immediate_ready_seq seq6;
  delayed_ready_seq seq7;
  reset_seq seq8;
  timing_seq seq9;
  transfer_during_access_seq seq10;
  pstrb_zero_seq seq11;
  read_invalid_seq seq12;

  `uvm_info("REG","Running Regression Sequences",UVM_MEDIUM)

  seq1 = single_write_seq::type_id::create("seq1");
  seq1.start(m_sequencer);

  seq2 = single_read_seq::type_id::create("seq2");
  seq2.start(m_sequencer);

  seq3 = back_to_back_seq::type_id::create("seq3");
  seq3.start(m_sequencer);

  seq4 = random_access_seq::type_id::create("seq4");
  seq4.start(m_sequencer);

  seq5 = error_seq::type_id::create("seq5");
  seq5.start(m_sequencer);

  seq6 = immediate_ready_seq::type_id::create("seq6");
  seq6.start(m_sequencer);

  seq7 = delayed_ready_seq::type_id::create("seq7");
  seq7.start(m_sequencer);

  seq8 = reset_seq::type_id::create("seq8");
  seq8.start(m_sequencer);

  seq9 = timing_seq::type_id::create("seq9");
  seq9.start(m_sequencer);

  seq10 = transfer_during_access_seq::type_id::create("seq10");
  seq10.start(m_sequencer);

  seq11 = pstrb_zero_seq::type_id::create("seq11");
  seq11.start(m_sequencer);

  seq12 = read_invalid_seq::type_id::create("seq12");
  seq12.start(m_sequencer);

  `uvm_info("REG","Regression Completed Successfully",UVM_MEDIUM)
endtask


endclass

~
~
