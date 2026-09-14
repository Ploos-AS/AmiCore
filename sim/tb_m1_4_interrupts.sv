`timescale 1ns/1ps

module tb_m1_4_interrupts;
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

        // Program: lower interrupt mask to 2, then execute NOPs.
        mem[16] = 16'h46FC; // MOVE #imm,SR
        mem[17] = 16'h2200; // supervisor, interrupt mask 2
        mem[18] = 16'h4E71; // 0x24
        mem[19] = 16'h4E71; // 0x26

        // Autovector level 3 = vector 27, vector address 0x6c -> handler 0x80.
        mem[54] = 16'h0000;
        mem[55] = 16'h0080;
        mem[64] = 16'h4E71;

        #20 reset_n = 1;

        wait (pc == 32'h00000024);
        #1;
        if (sr[10:8] !== 3'd2) $fatal(1, "MOVE #imm,SR did not set mask 2: SR=%h", sr);

        // Level 2 is masked and must not interrupt.
        irq_level = 3'd2;
        wait (pc == 32'h00000026);
        #1;
        if (exception) $fatal(1, "masked level-2 interrupt was accepted");

        // Level 3 outranks mask 2 and must use autovector 27.
        irq_level = 3'd3;
        wait (exception == 1'b1);
        if (exception_vector !== 8'd27)
            $fatal(1, "wrong level-3 autovector: %0d", exception_vector);

        wait (pc == 32'h00000080);
        irq_level = 3'd0;
        #1;
        if (a7 !== 32'h000001FA) $fatal(1, "wrong IRQ stack pointer: %h", a7);
        if (mem[16'hFD] !== 16'h2200) $fatal(1, "wrong stacked IRQ SR: %h", mem[16'hFD]);
        if (mem[16'hFE] !== 16'h0000) $fatal(1, "wrong stacked IRQ PC high: %h", mem[16'hFE]);
        if (mem[16'hFF] !== 16'h0026) $fatal(1, "wrong stacked IRQ PC low: %h", mem[16'hFF]);
        if (sr[10:8] !== 3'd3) $fatal(1, "interrupt mask not raised to level 3: SR=%h", sr);
        if (halted) $fatal(1, "core halted during interrupt entry");

        $display("PASS: M1.4 interrupt mask + level-3 autovector entry");
        $finish;
    end
endmodule
