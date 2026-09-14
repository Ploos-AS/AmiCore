// AmiCore M1 memory interface contract.
// Separate chip-RAM and ROM controllers may implement this interface.

interface amcore_memory_if #(parameter int ADDR_WIDTH = 32,
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
