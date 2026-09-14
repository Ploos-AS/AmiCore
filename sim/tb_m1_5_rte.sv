`timescale 1ns/1ps

module tb_m1_5_rte;
    logic clk = 0;
    logic reset_n = 0;
    logic [2:0] irq_level = 0;
    logic [31:0] address;
    logic [15:0] data_out, data_in;
    logic read, write, ack;
    logic [31:0] d0, pc, a7;
    logic [15:0] sr;
    logic halted, exception;
    logic [7:0] exception_vector;
    logic [15:0] mem [0:511];

    always #5 clk = ~clk;

    amcore_68k_baseline dut (
        .clk(clk), .reset_n(reset_n), .irq_level(irq_level),
        .address(address), .data_out(data_out), .data_in(data_in),
        .read(read), .write(write), .ack(ack), .d0(d0), .pc(pc),
        .a7(a7), .sr(sr), .halted(halted), .exception(exception),
        .exception_vector(exception_vector)
    );

    always_comb begin
        ack = read | write;
        data_in = mem[address[9:1]];
    end

    always_ff @(posedge clk) begin
        if (write && ack)
            mem[address[9:1]] <= data_out;
    end

    initial begin
        integer i;
        for (i = 0; i < 512; i = i + 1)
            mem[i] = 16'h4E71;

        // Reset SSP=0x200, PC=0x20.
        mem[0] = 16'h0000;
        mem[1] = 16'h0200;
        mem[2] = 16'h0000;
        mem[3] = 16'h0020;

        // Main: lower mask to 2, MOVEQ #-1,D0, then NOP at resume point.
        mem[16] = 16'h46FC; // MOVE #imm,SR
        mem[17] = 16'h2200; // supervisor, interrupt mask 2
        mem[18] = 16'h70FF; // MOVEQ #-1,D0, N must set
        mem[19] = 16'h4E71; // 0x26 resume point
        mem[20] = 16'h4280; // CLR.L D0, Z must set

        // Level-3 autovector (27) -> 0x80.
        mem[54] = 16'h0000;
        mem[55] = 16'h0080;
        mem[64] = 16'h4E73; // RTE

        #20 reset_n = 1;

        wait (pc == 32'h00000026);
        #1;
        if (d0 !== 32'hFFFFFFFF) $fatal(1, "MOVEQ result wrong: %h", d0);
        if (sr[3] !== 1'b1 || sr[2] !== 1'b0)
            $fatal(1, "MOVEQ N/Z flags wrong: SR=%h", sr);

        // Interrupt at the 0x26 instruction boundary.
        irq_level = 3'd3;
        wait (pc == 32'h00000080);
        #1 irq_level = 3'd0;
        if (a7 !== 32'h000001FA) $fatal(1, "IRQ frame SP wrong: %h", a7);
        if (sr[10:8] !== 3'd3) $fatal(1, "IRQ mask not raised: SR=%h", sr);

        // RTE must restore SR=0x2208 (N set) and PC=0x26, then restore A7.
        wait (pc == 32'h00000026 && a7 == 32'h00000200);
        #1;
        if (sr[10:8] !== 3'd2) $fatal(1, "RTE did not restore interrupt mask: SR=%h", sr);
        if (sr[3] !== 1'b1 || sr[2] !== 1'b0)
            $fatal(1, "RTE did not restore CCR N/Z: SR=%h", sr);

        // Let NOP at 0x26 and CLR.L at 0x28 execute.
        wait (pc == 32'h0000002A);
        #1;
        if (d0 !== 32'h00000000) $fatal(1, "CLR result wrong: %h", d0);
        if (sr[3] !== 1'b0 || sr[2] !== 1'b1)
            $fatal(1, "CLR N/Z flags wrong: SR=%h", sr);
        if (halted) $fatal(1, "core halted during RTE flow");

        $display("PASS: M1.5 RTE restores SR/PC/A7 and CCR N/Z baseline");
        $finish;
    end
endmodule
