`timescale 1ns/1ps

module tb_m1_2_cpu;
    logic clk = 0;
    logic reset_n = 0;
    logic [31:0] address;
    logic [15:0] data_out;
    logic [15:0] data_in;
    logic read;
    logic write;
    logic ack;
    logic [31:0] d0;
    logic [31:0] pc;
    logic halted;
    logic exception;
    logic [7:0] exception_vector;

    logic [15:0] mem [0:127];

    always #5 clk = ~clk;

    amcore_68k_baseline dut (
        .clk(clk), .reset_n(reset_n), .address(address), .data_out(data_out),
        .data_in(data_in), .read(read), .write(write), .ack(ack),
        .d0(d0), .pc(pc), .halted(halted), .exception(exception),
        .exception_vector(exception_vector)
    );

    always_comb begin
        ack = read | write;
        data_in = mem[address[8:1]];
    end

    initial begin
        integer i;
        for (i = 0; i < 128; i = i + 1)
            mem[i] = 16'h4E71;

        // Reset SSP = 0x00000100, PC = 0x00000020.
        mem[0] = 16'h0000;
        mem[1] = 16'h0100;
        mem[2] = 16'h0000;
        mem[3] = 16'h0020;

        // Illegal-instruction vector 4 -> 0x00000040.
        mem[8] = 16'h0000;
        mem[9] = 16'h0040;

        // Program: MOVEQ #5,D0; ADDQ.L #3,D0; SUBQ.L #1,D0; CLR.L D0; illegal.
        mem[16] = 16'h7005;
        mem[17] = 16'h5680;
        mem[18] = 16'h5380;
        mem[19] = 16'h4280;
        mem[20] = 16'hFFFF;

        #20 reset_n = 1;

        wait (pc == 32'h00000022);
        @(posedge clk);
        if (d0 !== 32'd5) $fatal(1, "MOVEQ failed: D0=%h", d0);

        wait (pc == 32'h00000024);
        @(posedge clk);
        if (d0 !== 32'd8) $fatal(1, "ADDQ failed: D0=%h", d0);

        wait (pc == 32'h00000026);
        @(posedge clk);
        if (d0 !== 32'd7) $fatal(1, "SUBQ failed: D0=%h", d0);

        wait (pc == 32'h00000028);
        @(posedge clk);
        if (d0 !== 32'd0) $fatal(1, "CLR failed: D0=%h", d0);

        wait (exception == 1'b1);
        if (exception_vector !== 8'd4)
            $fatal(1, "wrong exception vector: %0d", exception_vector);
        wait (pc == 32'h00000040);
        if (halted) $fatal(1, "exception entry unexpectedly halted core");

        $display("PASS: M1.2 ALU + illegal-instruction vector baseline");
        $finish;
    end
endmodule
