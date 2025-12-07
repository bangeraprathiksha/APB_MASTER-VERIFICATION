
`uvm_analysis_imp_decl(_act)
`uvm_analysis_imp_decl(_exp)

typedef enum {IDLE, SETUP, ACCESS} fsm_state_e;

class master_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(master_scoreboard)

    uvm_analysis_imp_act #(master_seq_item, master_scoreboard) act_imp;
    uvm_analysis_imp_exp #(master_seq_item, master_scoreboard) exp_imp;

    fsm_state_e fsm_state;

                master_seq_item act_q[$];
                master_seq_item pass_q[$];


    int match_count,mismatch_count;

    bit [`ADDR_WIDTH-1:0] exp_paddr;
    bit exp_pwrite;
    bit [`DATA_WIDTH-1:0] exp_pwdata;
    bit exp_error;
    bit exp_transfer_done;
    bit exp_psel;
    bit exp_penable;
    bit exp_pstrb;
    bit [`DATA_WIDTH-1:0] exp_rdata_out;


function new(string name, uvm_component parent);
  super.new(name, parent);
  act_imp = new("act_imp", this);
  exp_imp = new("exp_imp", this);
  fsm_state = IDLE;

  // initialize counters and expected fields
  match_count = 0;
  mismatch_count = 0;
  exp_paddr = '0;
  exp_pwrite = 0;
  exp_pwdata = '0;
  exp_error = 0;
  exp_transfer_done = 0;
  exp_psel = 0;
  exp_penable = 0;
  exp_pstrb = '0;
  exp_rdata_out = '0;
endfunction



function void write_act(master_seq_item tr);
  act_q.push_back(tr);
endfunction

function void write_exp(master_seq_item tr);
  pass_q.push_back(tr);
endfunction


task run_phase(uvm_phase phase);
  master_seq_item act_item;
  master_seq_item exp_item;

  forever begin
    wait(act_q.size()>0 && pass_q.size()>0);

    act_item = act_q.pop_front();
    exp_item = pass_q.pop_front();

    update_fsm(act_item);
     compare_with_passive(exp_item);
  end
endtask


    function void update_fsm(master_seq_item tr);

                exp_paddr  = tr.addr_in;
                exp_pwrite = tr.write_read;
                exp_pwdata = tr.wdata_in;
                exp_error = tr.pslverr;
                exp_pstrb = tr.strb_in;
                exp_rdata_out = tr.prdata;

        case (fsm_state)

            IDLE:
            if (tr.transfer == 1 && tr.presetn == 1) begin

                exp_psel = 0;
                exp_penable= 0;
                exp_paddr  = tr.addr_in;
                exp_pwrite = tr.write_read;
                exp_pwdata = tr.wdata_in;
                exp_error = tr.pslverr;
                exp_pstrb = tr.strb_in;
                exp_rdata_out = tr.prdata;
                exp_transfer_done = 0;


                `uvm_info("FSM_IDLE", $sformatf(
                    "IDLE : ((pready=%0d)) addr=%0h write=%0b wdata=%0h",
                    tr.pready,exp_paddr, exp_pwrite,exp_pwdata), UVM_LOW)
                fsm_state = SETUP;
             end

            SETUP: begin
                exp_psel = 1;
                exp_penable= 0;
                exp_paddr  = tr.addr_in;
                exp_pwrite = tr.write_read;
                exp_pwdata = tr.wdata_in;
                exp_error = tr.pslverr;
                exp_pstrb = tr.strb_in;
                exp_rdata_out = tr.prdata;
                exp_transfer_done = 0;
                `uvm_info("FSM_SETUP", $sformatf(
                    "SETUP : ((pready=%0d)) addr=%0h write=%0b wdata=%0h",
                    tr.pready,exp_paddr, exp_pwrite,exp_pwdata), UVM_LOW)
                fsm_state = ACCESS;
            end

            ACCESS:begin
           if (tr.pready == 1 && tr.transfer == 0) begin
                exp_psel = 1;
                exp_penable= 1;
                exp_paddr  = tr.addr_in;
                exp_pwrite = tr.write_read;
                exp_pwdata = tr.wdata_in;
                exp_error = tr.pslverr;
                exp_pstrb = tr.strb_in;
                exp_rdata_out = tr.prdata;
                exp_transfer_done = 1;

                `uvm_info("FSM_ACCESS", $sformatf(
                    "ACCESS : ((pready=%0d)) addr=%0h write=%0b wdata=%0h",
                    tr.pready,exp_paddr, exp_pwrite,exp_pwdata), UVM_LOW)
                fsm_state = IDLE;
                $display("pready = 1 then next_______\n\n");
            end
            else if(tr.pready == 1 && tr.transfer == 1)begin
                exp_psel = 1;
                exp_penable= 1;
                exp_paddr  = tr.addr_in;
                exp_pwrite = tr.write_read;
                exp_pwdata = tr.wdata_in;
                exp_error = tr.pslverr;
                exp_pstrb = tr.strb_in;
                exp_rdata_out = tr.prdata;
                exp_transfer_done = 1;
                fsm_state =IDLE;

            end
            else if(tr.pready == 0)begin
                exp_psel = 1;
                exp_penable= 1;
                exp_paddr  = tr.addr_in;
                exp_pwrite = tr.write_read;
                exp_pwdata = tr.wdata_in;
                exp_error = tr.pslverr;
                exp_pstrb = tr.strb_in;
                exp_rdata_out = tr.prdata;
                exp_transfer_done = 0;
                fsm_state = ACCESS;
                $display("______pready = %0d",tr.pready);
            end
        end
        endcase


    endfunction

 function void compare_with_passive(master_seq_item p);

        if(exp_psel == p.psel)begin
                match_count++;
                `uvm_info("SB", $sformatf("[MATCH] PSELx  EXP=%0h ACT=%0h",
                   exp_psel, p.psel), UVM_LOW)
        end else begin
                mismatch_count++;
                `uvm_error("SB", $sformatf("[MISMATCH] PSELx  EXP=%0h ACT=%0h",
                    exp_psel, p.psel))
        end
        if(exp_penable == p.penable)begin
                match_count++;
                `uvm_info("SB", $sformatf("[MATCH] Penable  EXP=%0h ACT=%0h",
                   exp_penable, p.penable), UVM_LOW)
        end else begin
                mismatch_count++;
                `uvm_error("SB", $sformatf("[MISMATCH] Penable  EXP=%0h ACT=%0h",
                    exp_penable, p.penable))
        end


      if (p.paddr === exp_paddr) begin
        match_count++;
        `uvm_info("SB", $sformatf("[MATCH] PADDR  EXP=%0h ACT=%0h",
                   exp_paddr, p.paddr), UVM_LOW)
      end else begin
        mismatch_count++;
        `uvm_error("SB", $sformatf("[MISMATCH] PADDR  EXP=%0h ACT=%0h",
                    exp_paddr, p.paddr))
      end

      if (p.pwrite === exp_pwrite) begin
        match_count++;
        `uvm_info("SB", $sformatf("[MATCH] PWRITE EXP=%0b ACT=%0b",
                   exp_pwrite, p.pwrite), UVM_LOW)
      end else begin
        mismatch_count++;
        `uvm_error("SB", $sformatf("[MISMATCH] PWRITE EXP=%0b ACT=%0b",
                    exp_pwrite, p.pwrite))
      end

      if (exp_pwrite) begin
        if (p.pwdata === exp_pwdata) begin
          match_count++;
          `uvm_info("SB", $sformatf("[MATCH] PWDATA EXP=%0h ACT=%0h",
                     exp_pwdata, p.pwdata), UVM_LOW)
        end else begin
          mismatch_count++;
          `uvm_error("SB", $sformatf("[MISMATCH] PWDATA EXP=%0h ACT=%0h",
                      exp_pwdata, p.pwdata))
        end
      end

      if (p.error === exp_error) begin
        match_count++;
        `uvm_info("SB", $sformatf("[MATCH] ERROR EXP=%0b ACT=%0b",
                   exp_error, p.error), UVM_LOW)
      end else begin
        mismatch_count++;
        `uvm_error("SB", $sformatf("[MISMATCH] ERROR EXP=%0b ACT=%0b",
                    exp_error, p.error))
      end

      if (p.transfer_done === exp_transfer_done) begin
        match_count++;
        `uvm_info("SB", $sformatf("[MATCH] DONE EXP=%0b ACT=%0b",
                   exp_transfer_done, p.transfer_done), UVM_LOW)
      end else begin
        mismatch_count++;
        `uvm_error("SB", $sformatf("[MISMATCH] DONE EXP=%0b ACT=%0b",
                    exp_transfer_done, p.transfer_done))
      end

  endfunction


  function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    `uvm_info("SB_SUMMARY",
      $sformatf("\n========== SCOREBOARD SUMMARY ==========\nMATCH COUNT     : %0d\nMISMATCH COUNT  : %0d\n=========================================\n",
      match_count, mismatch_count),
      UVM_NONE)
  endfunction


endclass
