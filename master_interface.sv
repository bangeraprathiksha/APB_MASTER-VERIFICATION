interface master_interface(input bit pclk);

    logic presetn;
    logic [`DATA_WIDTH-1:0] prdata;
    logic pready;
    logic pslverr;
    logic transfer;
    logic write_read;
    logic [`ADDR_WIDTH-1:0] addr_in;
    logic [`DATA_WIDTH-1:0] wdata_in;
    logic [`DATA_WIDTH/8-1:0] strb_in;

    logic [`ADDR_WIDTH-1:0] paddr;
    logic psel;
    logic penable;
    logic pwrite;
    logic [`DATA_WIDTH-1:0] pwdata;
    logic [`DATA_WIDTH/8-1:0] pstrb;
    logic [`DATA_WIDTH-1:0] rdata_out;
    logic transfer_done;
    logic error;

    // DRIVER
    clocking drv_cb @(posedge pclk);
        default input #0 output #0;
        output presetn, transfer, write_read, addr_in, wdata_in, strb_in;
        output  prdata, pslverr, pready;
    endclocking

    // ACTIVE MONITOR
    clocking mon_act_cb @(posedge pclk);
        default input #0 output #0;
        input presetn, transfer, write_read, addr_in, wdata_in, strb_in, prdata, pslverr, pready;
    endclocking

    // PASSIVE MONITOR
    clocking mon_pass_cb @(posedge pclk);
        default input #0 output #0;
        input paddr, psel, penable, pwrite, pwdata, pstrb, rdata_out, transfer_done, error;
        input pready;
        input prdata;
    endclocking

endinterface
