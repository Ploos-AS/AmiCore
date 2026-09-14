// AmiCore M1.2 — minimal 68000 execution baseline.
// Independently written clean-room execution core.
// Supported instructions: NOP, MOVEQ, BRA, ADDQ.L D0, SUBQ.L D0, CLR.L D0.
// Unsupported opcodes enter a deterministic illegal-instruction exception state.

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
    output logic        halted,
    output logic        exception,
    output logic [7:0]  exception_vector
);

    typedef enum logic [2:0] {
        S_RESET_HI,
        S_RESET_LO,
        S_FETCH,
        S_EXEC,
        S_EXCEPTION,
        S_HALT
    } state_t;

    state_t state;
    logic [15:0] ir;
    logic [31:0] reset_hi;
    logic [3:0] quick_value;

    always_comb begin
        address = 32'h0;
        data_out = 16'h0;
        read = 1'b0;
        write = 1'b0;
        quick_value = (ir[11:9] == 3'b000) ? 4'd8 : {1'b0, ir[11:9]};

        case (state)
            S_RESET_HI: begin address = 32'h00000000; read = 1'b1; end
            S_RESET_LO: begin address = 32'h00000002; read = 1'b1; end
            S_FETCH:    begin address = pc;          read = 1'b1; end
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
            exception <= 1'b0;
            exception_vector <= 8'h00;
        end else begin
            case (state)
                S_RESET_HI: if (ack) begin
                    reset_hi[31:16] <= data_in;
                    state <= S_RESET_LO;
                end

                S_RESET_LO: if (ack) begin
                    pc <= {reset_hi[31:16], data_in};
                    state <= S_FETCH;
                end

                S_FETCH: if (ack) begin
                    ir <= data_in;
                    state <= S_EXEC;
                end

                S_EXEC: begin
                    if (ir == 16'h4E71) begin
                        // NOP
                        pc <= pc + 32'd2;
                        state <= S_FETCH;
                    end else if ((ir & 16'hF100) == 16'h7000) begin
                        // MOVEQ #imm8,D0
                        d0 <= {{24{ir[7]}}, ir[7:0]};
                        pc <= pc + 32'd2;
                        state <= S_FETCH;
                    end else if ((ir & 16'hFF00) == 16'h6000 && ir[7:0] != 8'h00) begin
                        // BRA.s disp8
                        pc <= pc + 32'd2 + {{24{ir[7]}}, ir[7:0]};
                        state <= S_FETCH;
                    end else if ((ir & 16'hF1FF) == 16'h5080) begin
                        // ADDQ.L #n,D0
                        d0 <= d0 + quick_value;
                        pc <= pc + 32'd2;
                        state <= S_FETCH;
                    end else if ((ir & 16'hF1FF) == 16'h5180) begin
                        // SUBQ.L #n,D0
                        d0 <= d0 - quick_value;
                        pc <= pc + 32'd2;
                        state <= S_FETCH;
                    end else if (ir == 16'h4280) begin
                        // CLR.L D0
                        d0 <= 32'h00000000;
                        pc <= pc + 32'd2;
                        state <= S_FETCH;
                    end else begin
                        // Illegal instruction vector = 4 on MC68000.
                        exception <= 1'b1;
                        exception_vector <= 8'd4;
                        halted <= 1'b1;
                        state <= S_EXCEPTION;
                    end
                end

                S_EXCEPTION: state <= S_HALT;
                S_HALT:      state <= S_HALT;
                default:     state <= S_HALT;
            endcase
        end
    end
endmodule
