class master_seq_item extends uvm_sequence_item;
  `uvm_object_utils(master_seq_item)

bit exp_psel;
bit exp_penable;

  rand bit presetn;
  rand bit [`DATA_WIDTH-1:0] prdata;
  rand bit pready;
  rand bit pslverr;
  rand bit transfer;
  rand bit write_read;
  rand bit [`ADDR_WIDTH-1:0] addr_in;
  rand bit [`DATA_WIDTH-1:0] wdata_in;
  rand bit [`DATA_WIDTH/8-1:0] strb_in;

  bit [`ADDR_WIDTH-1:0] paddr;
  bit psel;
  bit pwrite;
  bit [`DATA_WIDTH-1:0] pwdata;
  bit [`DATA_WIDTH/8-1:0] pstrb;
  bit [`DATA_WIDTH-1:0] rdata_out;
  bit transfer_done;
  bit error;
  bit penable;

  function new(string name = "master_seq_item");
    super.new(name);
  endfunction
endclass
