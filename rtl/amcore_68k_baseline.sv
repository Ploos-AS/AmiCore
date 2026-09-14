// AmiCore M1.3 — minimal clean-room 68000 execution baseline.
// Supported instructions: NOP, MOVEQ, BRA.s, ADDQ.L D0, SUBQ.L D0, CLR.L D0.
// M1.3 adds 68000-style reset vectors and illegal-instruction exception entry.

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
    output logic [31:0] a7,
    output logic [15:0] sr,
    output logic        halted,
    output logic        exception,
    output logic [7:0]  exception_vector
);

    typedef enum logic [3:0] {
        S_RESET_SSP_HI,
        S_RESET_SSP_LO,
        S_RESET_PC_HI,
        S_RESET_PC_LO,
        S_FETCH,
        S_EXEC,
        S_EXC_PUSH_PC_LO,
        S_EXC_PUSH_PC_HI,
        S_EXC_PUSH_SR,
        S_EXC_VEC_HI,
        S_EXC_VEC_LO,
        S_HALT
    } state_t;

    state_t state;
    logic [15:0] ir;
    logic [15:0] reset_hi;
    logic [15:0] vector_hi;
    logic [31:0] exception_pc;
    logic [15:0] exception_sr;
    logic [3:0] quick_value;

    always_comb begin
        address = 32'h0;
        data_out = 16'h0;
        read = 1'b0;
        write = 1'b0;
        quick_value = (ir[11:9] == 3'b000) ? 4'd8 : {1'b0, ir[11:9]};

        case (state)
            S_RESET_SSP_HI: begin address = 32'h00000000; read = 1'b1; end
            S_RESET_SSP_LO: begin address = 32'h00000002; read = 1'b1; end
            S_RESET_PC_HI:  begin address = 32'h00000004; read = 1'b1; end
            S_RESET_PC_LO:  begin address = 32'h00000006; read = 1'b1; end
            S_FETCH: begin
                address = pc;
                read = 1'b1;
            end
            S_EXC_PUSH_PC_LO: begin
                address = a7 - 32'd2;
                data_out = exception_pc[15:0];
                write = 1'b1;
            end
            S_EXC_PUSH_PC_HI: begin
                address = a7 - 32'd2;
                data_out = exception_pc[31:16];
                write = 1'b1;
            end
            S_EXC_PUSH_SR: begin
                address = a7 - 32'd2;
                data_out = exception_sr;
                write = 1'b1;
            end
            S_EXC_VEC_HI: begin
                address = {22'h0, exception_vector, 2'b00};
                read = 1'b1;
            end
            S_EXC_VEC_LO: begin
                address = {22'h0, exception_vector, 2'b00} + 32'd2;
                read = 1'b1;
            end
            default: begin end
        endcase
    end

    always_ff @(posedge clk) begin
        if (!reset_n) begin
            state <= S_RESET_SSP_HI;
            reset_hi <= 16'h0;
            vector_hi <= 16'h0;
            exception_pc <= 32'h0;
            exception_sr <= 16'h0;
            pc <= 32'h0;
            a7 <= 32'h0;
            d0 <= 32'h0;
            sr <= 16'h2700; // supervisor, interrupt mask 7 after reset
            ir <= 16'h0;
            halted <= 1'b0;
            exception <= 1'b0;
            exception_vector <= 8'h00;
        end else begin
            case (state)
                S_RESET_SSP_HI: if (ack) begin
                    reset_hi <= data_in;
                    state <= S_RESET_SSP_LO;
                end
                S_RESET_SSP_LO: if (ack) begin
                    a7 <= {reset_hi, data_in};
                    state <= S_RESET_PC_HI;
                end
                S_RESET_PC_HI: if (ack) begin
                    reset_hi <= data_in;
                    state <= S_RESET_PC_LO;
                end
                S_RESET_PC_LO: if (ack) begin
                    pc <= {reset_hi, data_in};
                    state <= S_FETCH;
                end
                S_FETCH: if (ack) begin
                    ir <= data_in;
                    state <= S_EXEC;
                end
                S_EXEC: begin
                    if (ir == 16'h4E71) begin
                        pc <= pc + 32'd2;
                        state <= S_FETCH;
                    end else if ((ir & 16'hF100) == 16'h7000) begin
                        d0 <= {{24{ir[7]}}, ir[7:0]};
                        pc <= pc + 32'd2;
                        state <= S_FETCH;
                    end else if ((ir & 16'hFF00) == 16'h6000 && ir[7:0] != 8'h00) begin
                        pc <= pc + 32'd2 + {{24{ir[7]}}, ir[7:0]};
                        state <= S_FETCH;
                    end else if ((ir & 16'hF1FF) == 16'h5080) begin
                        d0 <= d0 + quick_value;
                        pc <= pc + 32'd2;
                        state <= S_FETCH;
                    end else if ((ir & 16'hF1FF) == 16'h5180) begin
                        d0 <= d0 - quick_value;
                        pc <= pc + 32'd2;
                        state <= S_FETCH;
                    end else if (ir == 16'h4280) begin
                        d0 <= 32'h00000000;
                        pc <= pc + 32'd2;
                        state <= S_FETCH;
                    end else begin
                        // Illegal instruction: vector 4. The saved PC identifies
                        // the offending opcode in this baseline.
                        exception <= 1'b1;
                        exception_vector <= 8'd4;
                        exception_pc <= pc;
                        exception_sr <= sr;
                        sr[13] <= 1'b1; // supervisor mode
                        state <= S_EXC_PUSH_PC_LO;
                    end
                end
                S_EXC_PUSH_PC_LO: if (ack) begin
                    a7 <= a7 - 32'd2;
                    state <= S_EXC_PUSH_PC_HI;
                end
                S_EXC_PUSH_PC_HI: if (ack) begin
                    a7 <= a7 - 32'd2;
                    state <= S_EXC_PUSH_SR;
                end
                S_EXC_PUSH_SR: if (ack) begin
                    a7 <= a7 - 32'd2;
                    state <= S_EXC_VEC_HI;
                end
                S_EXC_VEC_HI: if (ack) begin
                    vector_hi <= data_in;
                    state <= S_EXC_VEC_LO;
                end
                S_EXC_VEC_LO: if (ack) begin
                    pc <= {vector_hi, data_in};
                    exception <= 1'b0;
                    state <= S_FETCH;
                end
                S_HALT: state <= S_HALT;
                default: begin
                    halted <= 1'b1;
                    state <= S_HALT;
                end
            endcase
        end
    end
endmodule
