// AmiCore M1.17 — reusable effective-address generator baseline.
// Supported forms:
//   mode 0: (An)
//   mode 1: d16(An)
//   mode 2: xxx.W (sign-extended absolute short)
//   mode 3: xxx.L (absolute long)
module amcore_ea(
    input  logic [1:0]  mode,
    input  logic [31:0] address_register,
    input  logic [15:0] extension_hi,
    input  logic [15:0] extension_lo,
    output logic [31:0] effective_address,
    output logic [2:0]  extension_bytes
);
    always_comb begin
        effective_address = address_register;
        extension_bytes = 3'd0;

        case (mode)
            2'd0: begin
                effective_address = address_register;
                extension_bytes = 3'd0;
            end
            2'd1: begin
                effective_address = address_register + {{16{extension_hi[15]}}, extension_hi};
                extension_bytes = 3'd2;
            end
            2'd2: begin
                effective_address = {{16{extension_hi[15]}}, extension_hi};
                extension_bytes = 3'd2;
            end
            2'd3: begin
                effective_address = {extension_hi, extension_lo};
                extension_bytes = 3'd4;
            end
        endcase
    end
endmodule
