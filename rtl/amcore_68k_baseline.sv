// AmiCore M1.7 — minimal clean-room 68000 execution baseline.
// Supported instructions include NOP, MOVEQ Dn, BRA.s, ADDQ.L/SUBQ.L/CLR.L Dn,
// register-direct MOVE.L/MOVEA.L, MOVE.L via (An)/(An)+/-(An), MOVE #imm,SR and RTE.
// M1.7 adds the first data-memory addressing modes for 32-bit MOVE transfers.

module amcore_68k_baseline (
    input  logic        clk,
    input  logic        reset_n,
    input  logic [2:0]  irq_level,
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

    typedef enum logic [4:0] {
        S_RESET_SSP_HI, S_RESET_SSP_LO, S_RESET_PC_HI, S_RESET_PC_LO,
        S_FETCH, S_EXEC, S_IMM_SR,
        S_EXC_PUSH_PC_LO, S_EXC_PUSH_PC_HI, S_EXC_PUSH_SR,
        S_EXC_VEC_HI, S_EXC_VEC_LO,
        S_RTE_POP_SR, S_RTE_POP_PC_HI, S_RTE_POP_PC_LO,
        S_MEM_RD_HI, S_MEM_RD_LO, S_MEM_WR_HI, S_MEM_WR_LO,
        S_HALT
    } state_t;

    state_t state;
    logic [31:0] dreg [0:7];
    logic [31:0] areg [0:7];
    logic [15:0] ir, reset_hi, vector_hi, rte_pc_hi;
    logic [31:0] exception_pc;
    logic [15:0] exception_sr;
    logic [3:0] quick_value;
    logic irq_pending;
    logic [31:0] alu_result;
    logic [31:0] mem_ea;
    logic [31:0] mem_value;
    logic [2:0] mem_dreg;
    logic [2:0] mem_areg;
    logic [1:0] mem_update;
    integer i;

    localparam logic [1:0] MEM_NO_UPDATE = 2'd0;
    localparam logic [1:0] MEM_POSTINC   = 2'd1;
    localparam logic [1:0] MEM_PREDEC    = 2'd2;

    assign d0 = dreg[0];
    assign a7 = areg[7];

    always_comb begin
        address = 32'h0;
        data_out = 16'h0;
        read = 1'b0;
        write = 1'b0;
        quick_value = (ir[11:9] == 3'b000) ? 4'd8 : {1'b0, ir[11:9]};
        irq_pending = (irq_level != 3'd0) && ((irq_level == 3'd7) || (irq_level > sr[10:8]));
        alu_result = dreg[ir[2:0]];
        if ((ir & 16'hF1F8) == 16'h5080) alu_result = dreg[ir[2:0]] + quick_value;
        else if ((ir & 16'hF1F8) == 16'h5180) alu_result = dreg[ir[2:0]] - quick_value;

        case (state)
            S_RESET_SSP_HI: begin address=32'h0; read=1'b1; end
            S_RESET_SSP_LO: begin address=32'h2; read=1'b1; end
            S_RESET_PC_HI:  begin address=32'h4; read=1'b1; end
            S_RESET_PC_LO:  begin address=32'h6; read=1'b1; end
            S_FETCH: if (!irq_pending) begin address=pc; read=1'b1; end
            S_IMM_SR: begin address=pc+32'd2; read=1'b1; end
            S_EXC_PUSH_PC_LO: begin address=areg[7]-32'd2; data_out=exception_pc[15:0]; write=1'b1; end
            S_EXC_PUSH_PC_HI: begin address=areg[7]-32'd2; data_out=exception_pc[31:16]; write=1'b1; end
            S_EXC_PUSH_SR: begin address=areg[7]-32'd2; data_out=exception_sr; write=1'b1; end
            S_EXC_VEC_HI: begin address={22'h0,exception_vector,2'b00}; read=1'b1; end
            S_EXC_VEC_LO: begin address={22'h0,exception_vector,2'b00}+32'd2; read=1'b1; end
            S_RTE_POP_SR, S_RTE_POP_PC_HI, S_RTE_POP_PC_LO: begin address=areg[7]; read=1'b1; end
            S_MEM_RD_HI: begin address=mem_ea; read=1'b1; end
            S_MEM_RD_LO: begin address=mem_ea+32'd2; read=1'b1; end
            S_MEM_WR_HI: begin address=mem_ea; data_out=mem_value[31:16]; write=1'b1; end
            S_MEM_WR_LO: begin address=mem_ea+32'd2; data_out=mem_value[15:0]; write=1'b1; end
            default: begin end
        endcase
    end

    always_ff @(posedge clk) begin
        if (!reset_n) begin
            state<=S_RESET_SSP_HI; reset_hi<=0; vector_hi<=0; rte_pc_hi<=0;
            exception_pc<=0; exception_sr<=0; pc<=0; sr<=16'h2700; ir<=0;
            halted<=0; exception<=0; exception_vector<=0;
            mem_ea<=0; mem_value<=0; mem_dreg<=0; mem_areg<=0; mem_update<=MEM_NO_UPDATE;
            for (i=0;i<8;i=i+1) begin dreg[i]<=0; areg[i]<=0; end
        end else begin
            case (state)
                S_RESET_SSP_HI: if(ack) begin reset_hi<=data_in; state<=S_RESET_SSP_LO; end
                S_RESET_SSP_LO: if(ack) begin areg[7]<={reset_hi,data_in}; state<=S_RESET_PC_HI; end
                S_RESET_PC_HI: if(ack) begin reset_hi<=data_in; state<=S_RESET_PC_LO; end
                S_RESET_PC_LO: if(ack) begin pc<={reset_hi,data_in}; state<=S_FETCH; end
                S_FETCH: begin
                    if(irq_pending) begin
                        exception<=1; exception_vector<=8'd24+{5'd0,irq_level}; exception_pc<=pc; exception_sr<=sr;
                        sr[13]<=1; sr[10:8]<=irq_level; state<=S_EXC_PUSH_PC_LO;
                    end else if(ack) begin ir<=data_in; state<=S_EXEC; end
                end
                S_EXEC: begin
                    if(ir==16'h4E71) begin pc<=pc+2; state<=S_FETCH; end
                    else if((ir & 16'hF100)==16'h7000) begin
                        dreg[ir[11:9]]<={{24{ir[7]}},ir[7:0]}; sr[3]<=ir[7]; sr[2]<=(ir[7:0]==0); sr[1:0]<=0;
                        pc<=pc+2; state<=S_FETCH;
                    end else if((ir & 16'hFF00)==16'h6000 && ir[7:0]!=0) begin pc<=pc+2+{{24{ir[7]}},ir[7:0]}; state<=S_FETCH; end
                    else if((ir & 16'hF1F8)==16'h5080 || (ir & 16'hF1F8)==16'h5180) begin
                        dreg[ir[2:0]]<=alu_result; sr[3]<=alu_result[31]; sr[2]<=(alu_result==0); sr[1:0]<=0; pc<=pc+2; state<=S_FETCH;
                    end else if((ir & 16'hFFF8)==16'h4280) begin
                        dreg[ir[2:0]]<=0; sr[3]<=0; sr[2]<=1; sr[1:0]<=0; pc<=pc+2; state<=S_FETCH;
                    end else if(ir[15:12]==4'h2 && ir[8:6]==3'b000 && ir[5:3]==3'b000) begin
                        // MOVE.L Dm,Dn.
                        dreg[ir[11:9]]<=dreg[ir[2:0]]; sr[3]<=dreg[ir[2:0]][31]; sr[2]<=(dreg[ir[2:0]]==0); sr[1:0]<=0;
                        pc<=pc+2; state<=S_FETCH;
                    end else if(ir[15:12]==4'h2 && ir[8:6]==3'b001 && ir[5:3]==3'b001) begin
                        // MOVEA.L Am,An; CCR unchanged.
                        areg[ir[11:9]]<=areg[ir[2:0]]; pc<=pc+2; state<=S_FETCH;
                    end else if(ir[15:12]==4'h2 && ir[8:6]==3'b000 &&
                                (ir[5:3]==3'b010 || ir[5:3]==3'b011 || ir[5:3]==3'b100)) begin
                        // MOVE.L (An)/(An)+/-(An),Dn.
                        mem_dreg<=ir[11:9]; mem_areg<=ir[2:0]; mem_update<=MEM_NO_UPDATE;
                        if(ir[5:3]==3'b100) begin
                            mem_ea<=areg[ir[2:0]]-32'd4; areg[ir[2:0]]<=areg[ir[2:0]]-32'd4; mem_update<=MEM_PREDEC;
                        end else begin
                            mem_ea<=areg[ir[2:0]];
                            if(ir[5:3]==3'b011) mem_update<=MEM_POSTINC;
                        end
                        state<=S_MEM_RD_HI;
                    end else if(ir[15:12]==4'h2 && ir[5:3]==3'b000 &&
                                (ir[8:6]==3'b010 || ir[8:6]==3'b011 || ir[8:6]==3'b100)) begin
                        // MOVE.L Dm,(An)/(An)+/-(An).
                        mem_value<=dreg[ir[2:0]]; mem_areg<=ir[11:9]; mem_update<=MEM_NO_UPDATE;
                        sr[3]<=dreg[ir[2:0]][31]; sr[2]<=(dreg[ir[2:0]]==0); sr[1:0]<=0;
                        if(ir[8:6]==3'b100) begin
                            mem_ea<=areg[ir[11:9]]-32'd4; areg[ir[11:9]]<=areg[ir[11:9]]-32'd4; mem_update<=MEM_PREDEC;
                        end else begin
                            mem_ea<=areg[ir[11:9]];
                            if(ir[8:6]==3'b011) mem_update<=MEM_POSTINC;
                        end
                        state<=S_MEM_WR_HI;
                    end else if(ir==16'h46FC) begin
                        if(sr[13]) state<=S_IMM_SR;
                        else begin exception<=1; exception_vector<=8'd8; exception_pc<=pc; exception_sr<=sr; sr[13]<=1; state<=S_EXC_PUSH_PC_LO; end
                    end else if(ir==16'h4E73) begin
                        if(sr[13]) state<=S_RTE_POP_SR;
                        else begin exception<=1; exception_vector<=8'd8; exception_pc<=pc; exception_sr<=sr; sr[13]<=1; state<=S_EXC_PUSH_PC_LO; end
                    end else begin exception<=1; exception_vector<=8'd4; exception_pc<=pc; exception_sr<=sr; sr[13]<=1; state<=S_EXC_PUSH_PC_LO; end
                end
                S_MEM_RD_HI: if(ack) begin mem_value[31:16]<=data_in; state<=S_MEM_RD_LO; end
                S_MEM_RD_LO: if(ack) begin
                    mem_value[15:0]<=data_in;
                    dreg[mem_dreg]<={mem_value[31:16],data_in};
                    sr[3]<=mem_value[31]; sr[2]<=({mem_value[31:16],data_in}==0); sr[1:0]<=0;
                    if(mem_update==MEM_POSTINC) areg[mem_areg]<=areg[mem_areg]+32'd4;
                    pc<=pc+2; state<=S_FETCH;
                end
                S_MEM_WR_HI: if(ack) state<=S_MEM_WR_LO;
                S_MEM_WR_LO: if(ack) begin
                    if(mem_update==MEM_POSTINC) areg[mem_areg]<=areg[mem_areg]+32'd4;
                    pc<=pc+2; state<=S_FETCH;
                end
                S_IMM_SR: if(ack) begin sr<=data_in; pc<=pc+4; state<=S_FETCH; end
                S_EXC_PUSH_PC_LO: if(ack) begin areg[7]<=areg[7]-2; state<=S_EXC_PUSH_PC_HI; end
                S_EXC_PUSH_PC_HI: if(ack) begin areg[7]<=areg[7]-2; state<=S_EXC_PUSH_SR; end
                S_EXC_PUSH_SR: if(ack) begin areg[7]<=areg[7]-2; state<=S_EXC_VEC_HI; end
                S_EXC_VEC_HI: if(ack) begin vector_hi<=data_in; state<=S_EXC_VEC_LO; end
                S_EXC_VEC_LO: if(ack) begin pc<={vector_hi,data_in}; exception<=0; state<=S_FETCH; end
                S_RTE_POP_SR: if(ack) begin sr<=data_in; areg[7]<=areg[7]+2; state<=S_RTE_POP_PC_HI; end
                S_RTE_POP_PC_HI: if(ack) begin rte_pc_hi<=data_in; areg[7]<=areg[7]+2; state<=S_RTE_POP_PC_LO; end
                S_RTE_POP_PC_LO: if(ack) begin pc<={rte_pc_hi,data_in}; areg[7]<=areg[7]+2; state<=S_FETCH; end
                S_HALT: state<=S_HALT;
                default: begin halted<=1; state<=S_HALT; end
            endcase
        end
    end
endmodule
