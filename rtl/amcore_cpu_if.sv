// AmiCore M1 CPU integration boundary.
// A CPU implementation can be replaced without changing the system bus contract.

interface amcore_cpu_if;
    logic [31:0] address;
    logic [15:0] write_data;
    logic [15:0] read_data;
    logic        read;
    logic        write;
    logic        uds;
    logic        lds;
    logic        cycle;
    logic        ready;
    logic        bus_error;
    logic [2:0]  interrupt_level;
    logic        reset_request;

    modport cpu (
        output address, write_data, read, write, uds, lds, cycle, reset_request,
        input  read_data, ready, bus_error, interrupt_level
    );

    modport system (
        input  address, write_data, read, write, uds, lds, cycle, reset_request,
        output read_data, ready, bus_error, interrupt_level
    );
endinterface
