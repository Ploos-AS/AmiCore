// AmiCore M1 board-independent system bus contract.
// This is an integration boundary, not yet an Amiga chipset implementation.

interface amcore_bus_if #(parameter int ADDR_WIDTH = 32,
                          parameter int DATA_WIDTH = 16);
    logic [ADDR_WIDTH-1:0] addr;
    logic [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH-1:0] rdata;
    logic                  write;
    logic                  valid;
    logic                  ready;
    logic                  error;

    modport master (
        output addr, wdata, write, valid,
        input  rdata, ready, error
    );

    modport slave (
        input  addr, wdata, write, valid,
        output rdata, ready, error
    );
endinterface
