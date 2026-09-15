`timescale 1ns/1ps

module tb_m1_9_address_registers;
    logic clk = 1'b0;
    logic reset_n = 1'b0;
    logic [2:0] irq_level = 3'd0;
    logic [31:0] address;
    logic [15:0] data_out;
    logic [15:0] data_in;
    logic read, write, ack;
    logic [31:0] d0, pc, a7;
    logic [15:0] sr;
    logic halted, exception;
    logic [7:0] exception_vector;
    logic [15:0] ram [0:511];
    integer cycles;

    amcore_68k_baseline dut (
        .clk(clk), .reset_n(reset_n), .irq_level(irq_level),
        .address(address), .data_out(data_out), .data_in(data_in),
        .read(read), .write(write), .ack(ack), .d0(d0), .pc(pc), .a7(a7),
        .sr(sr), .halted(halted), .exception(exception),
        .exception_vector(exception_vector)
    );

    always #5 clk = ~clk;
    assign ack = read | write;

    always_comb begin
        case (address)
            32'h00000000: data_in = 16'h0000;
            32'h00000002: data_in = 16'h0200;
            32'h00000004: data_in = 16'h0000;
            32'h00000006: data_in = 16'h0020;
            32'h00000020: data_in = 16'h204F; // MOVEA.L A7,A0
            32'h00000022: data_in = 16'h2248; // MOVEA.L A0,A1
            32'h00000024: data_in = 16'h2449; // MOVEA.L A1,A2
            32'h00000026: data_in = 16'h264A; // MOVEA.L A2,A3
            32'h00000028: data_in = 16'h284B; // MOVEA.L A3,A4
            32'h0000002A: data_in = 16'h2A4C; // MOVEA.L A4,A5
            32'h0000002C: data_in = 16'h2C4D; // MOVEA.L A5,A6
            32'h0000002E: data_in = 16'h7212; // MOVEQ #$12,D1
            32'h00000030: data_in = 16'h2081; // MOVE.L D1,(A0)
            32'h00000032: data_in = 16'h2E10; // MOVE.L (A0),D7
            32'h00000034: data_in = 16'h4E71; // NOP
            default: data_in = ram[address[10:1]];
        endcase
    end

    always_ff @(posedge clk) begin
        if (write && ack)
            ram[address[10:1]] <= data_out;
    end

    initial begin
        for (cycles = 0; cycles < 512; cycles = cycles + 1)
            ram[cycles] = 16'h0000;

        repeat (2) @(posedge clk);
        reset_n = 1'b1;

        cycles = 0;
        while (pc != 32'h00000034 && cycles < 300) begin
            @(posedge clk);
            cycles = cycles + 1;
        end

        if (cycles >= 300) $fatal(1, "M1.9 timeout");
        if (dut.areg[0] !== 32'h00000200) $fatal(1, "A0 mismatch");
        if (dut.areg[1] !== 32'h00000200) $fatal(1, "A1 mismatch");
        if (dut.areg[2] !== 32'h00000200) $fatal(1, "A2 mismatch");
        if (dut.areg[3] !== 32'h00000200) $fatal(1, "A3 mismatch");
        if (dut.areg[4] !== 32'h00000200) $fatal(1, "A4 mismatch");
        if (dut.areg[5] !== 32'h00000200) $fatal(1, "A5 mismatch");
        if (dut.areg[6] !== 32'h00000200) $fatal(1, "A6 mismatch");
        if (a7 !== 32'h00000200) $fatal(1, "A7 mismatch");
        if (dut.dreg[7] !== 32'h00000012) $fatal(1, "D7 memory load mismatch");
        if ({ram[16'h0100], ram[16'h0101]} !== 32'h00000012) $fatal(1, "memory mismatch");
        if (halted || exception) $fatal(1, "unexpected halt/exception");

        $display("PASS: M1.9 A0-A7 MOVEA chain + D7 memory transfer");
        $finish;
    end
endmodule
