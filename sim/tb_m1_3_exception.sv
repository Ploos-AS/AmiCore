`timescale 1ns/1ps

module tb_m1_3_exception;
    logic clk = 0;
    logic reset_n = 0;
    logic [31:0] address;
    logic [15:0] data_out;
    logic [15:0] data_in;
    logic read, write, ack;
    logic [31:0] d0, pc, a7;
    logic [15:0] sr;
    logic halted, exception;
    logic [7:0] exception_vector;
    logic [15:0] mem [0:511];

    always #5 clk = ~clk;

    amcore_68k_baseline dut (
        .clk(clk), .reset_n(reset_n), .irq_level(3'd0), .address(address), .data_out(data_out),
        .data_in(data_in), .read(read), .write(write), .ack(ack),
        .d0(d0), .pc(pc), .a7(a7), .sr(sr), .halted(halted),
        .exception(exception), .exception_vector(exception_vector)
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
        mem[0] = 16'h0000;
        mem[1] = 16'h0100;
        mem[2] = 16'h0000;
        mem[3] = 16'h0020;
        mem[8] = 16'h0000;
        mem[9] = 16'h0040;
        mem[16] = 16'hFFFF;
        mem[32] = 16'h4E71;
        #20 reset_n = 1;
        wait (pc == 32'h00000040);
        #1;
        if (a7 !== 32'h000000FA) $fatal(1, "wrong exception SP: %h", a7);
        if (mem[16'h7D] !== 16'h2700) $fatal(1, "wrong stacked SR: %h", mem[16'h7D]);
        if (mem[16'h7E] !== 16'h0000) $fatal(1, "wrong stacked PC high: %h", mem[16'h7E]);
        if (mem[16'h7F] !== 16'h0020) $fatal(1, "wrong stacked PC low: %h", mem[16'h7F]);
        if (sr[13] !== 1'b1) $fatal(1, "supervisor bit not set");
        if (halted) $fatal(1, "core halted during exception entry");
        if (exception) $fatal(1, "exception flag not cleared after vector fetch");
        if (exception_vector !== 8'd4) $fatal(1, "wrong exception vector");
        $display("PASS: M1.3 reset SSP/PC + vector 4 stack frame + handler fetch");
        $finish;
    end
endmodule
