// AmiCore M1.17 — LEA/PEA execution primitive.
// This helper consumes an already-generated effective address.
// LEA writes the EA to the selected address register.
// PEA requests a 32-bit push of the EA and leaves CCR unchanged.
module amcore_lea_pea(
    input  logic        is_pea,
    input  logic [2:0]  destination_areg,
    input  logic [31:0] effective_address,
    output logic        write_areg,
    output logic [2:0]  write_areg_index,
    output logic [31:0] write_areg_value,
    output logic        push_long,
    output logic [31:0] push_value
);
    always_comb begin
        write_areg = !is_pea;
        write_areg_index = destination_areg;
        write_areg_value = effective_address;
        push_long = is_pea;
        push_value = effective_address;
    end
endmodule
