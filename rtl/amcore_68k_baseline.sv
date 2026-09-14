// AmiCore M1.1 — minimal 68000 execution baseline.
// This is an independently written execution core, not a proprietary netlist.
// Supported instructions in M1.1: NOP, MOVEQ, BRA, RESET vector fetch.

module amcore_68k_baseline (
    input  logic        clk,
    input  logic        reset_n,
    output logic [31:0] address,
    output logic [15:0] data_out,
    input  logic [15:0] data_in,
    output logic        read,
    output logic        write,
    input  logic        ack,
    output logic [31:0] d0,
    output logic [31:0] pc,
    output logic        halted
);

    typedef enum logic [2:0] {S_RESET_HI, S_RESET_LO, S_FETCH, S_EXEC, S_HALT} state_t;
    state_t state;
    logic [15:0] ir;
    logic [31:0] reset_hi;

    always_comb begin
        address = 32'h0;
        data_out = 16'h0;
        read = 1'b0;
        write = 1'b0;
        case (state)
            S_RESET_HI: begin address = 32'h00000000; read = 1'b1; end
            S_RESET_LO: begin address = 32'h00000002; read = 1'b1; end
            S_FETCH: begin address = pc; read = 1'b1; end
            default: begin end
        endcase
    end

    always_ff @(posedge clk) begin
        if (!reset_n) begin
            state <= S_RESET_HI;
            reset_hi <= 32'h0;
            pc <= 32'h0;
            d0 <= 32'h0;
            ir <= 16'h0;
            halted <= 1'b0;
        end else begin
            case (state)
                S_RESET_HI: if (ack) begin reset_hi[31:16] <= data_in; state <= S_RESET_LO; end
                S_RESET_LO: if (ack) begin pc <= {reset_hi[31:16], data_in}; state <= S_FETCH; end
                S_FETCH: if (ack) begin ir <= data_in; state <= S_EXEC; end
                S_EXEC: begin
                    if (ir == 16'h4E71) begin
                        pc <= pc + 32'd2;
                        state <= S_FETCH;
                    end else if ((ir & 16'hF100) == 16'h7000) begin
                        d0 <= {{24{ir[7]}}, ir[7:0]};
                        pc <= pc + 32'd2;
                        state <= S_FETCH;
                    end else if ((ir & 16'hFF00) == 16'h6000) begin
                        pc <= pc + 32'd2 + {{24{ir[7]}}, ir[7:0]};
                        state <= S_FETCH;
                    end else begin
                        halted <= 1'b1;
                        state <= S_HALT;
                    end
                end
                S_HALT: state <= S_HALT;
                default: state <= S_HALT;
            endcase
        end
    end
endmodule
