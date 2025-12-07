`include "design.v"
`include "uvm_macros.svh"
import uvm_pkg::*;

`include "defines.svh"
`include "package.sv"
import master_package::*;

`include "master_interface.sv"

module top;

    bit pclk;
    bit presetn;

    master_interface master_vif(pclk);

     apb_master #(
        .ADDR_WIDTH(`ADDR_WIDTH),
        .DATA_WIDTH(`DATA_WIDTH)
    ) dut (
        .PCLK         (pclk),
        .PRESETn      (master_vif.presetn),

        // APB Master Interface
        .PADDR        (master_vif.paddr),
        .PSEL         (master_vif.psel),
        .PENABLE      (master_vif.penable),
        .PWRITE       (master_vif.pwrite),
        .PWDATA       (master_vif.pwdata),
        .PSTRB        (master_vif.pstrb),
        .PRDATA       (master_vif.prdata),
        .PREADY       (master_vif.pready),
        .PSLVERR      (master_vif.pslverr),

        // User Interface
        .transfer     (master_vif.transfer),
        .write_read   (master_vif.write_read),
        .addr_in      (master_vif.addr_in),
        .wdata_in     (master_vif.wdata_in),
        .strb_in      (master_vif.strb_in),
        .rdata_out    (master_vif.rdata_out),
        .transfer_done(master_vif.transfer_done),
        .error        (master_vif.error)
    );

    initial begin
        pclk = 0;
        forever #5 pclk = ~pclk;
    end


    initial begin
        uvm_config_db#(virtual master_interface)::set(null, "*", "vif", master_vif);
    end

    initial begin
        //run_test("apb_test");
        run_test("regression_test");
    end

    initial begin
        if ($test$plusargs("vcd")) begin
            $dumpfile("apb_master.vcd");
            $dumpvars(0, top);
        end
    end

   /* initial begin
        #500;
        $display("Simulation timeout!");
        $finish;
    end*/
endmodule
