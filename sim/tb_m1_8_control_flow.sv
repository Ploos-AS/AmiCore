module tb_m1_8_control_flow;
    logic clk = 1'b0;
    logic reset_n = 1'b0;
    logic [31:0] address, d0, pc, a7;
    logic [15:0] data_out, data_in, sr;
    logic read, write, ack, halted, exception;
    logic [7:0] exception_vector;
    logic [15:0] mem [0:255];
    integer i;

    amcore_68k_baseline dut (
        .clk(clk), .reset_n(reset_n), .irq_level(3'd0),
        .address(address), .data_out(data_out), .data_in(data_in),
        .read(read), .write(write), .ack(ack), .d0(d0), .pc(pc), .a7(a7),
        .sr(sr), .halted(halted), .exception(exception), .exception_vector(exception_vector)
    );

    always #5 clk = ~clk;

    always_comb begin
        ack = read | write;
        data_in = mem[address[9:1]];
    end

    always_ff @(posedge clk) begin
        if (write && ack)
            mem[address[9:1]] <= data_out;
    end

    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 16'h4E71;

        // Reset vectors: SSP=$00000200, PC=$00000020.
        mem[16'h0000 >> 1] = 16'h0000;
        mem[16'h0002 >> 1] = 16'h0200;
        mem[16'h0004 >> 1] = 16'h0000;
        mem[16'h0006 >> 1] = 16'h0020;

        // Main: BSR.w $40; on return BRA.w $2e; skipped path at $28.
        mem[16'h0020 >> 1] = 16'h6100;
        mem[16'h0022 >> 1] = 16'h001e; // $22 + $1e = $40
        mem[16'h0024 >> 1] = 16'h6000;
        mem[16'h0026 >> 1] = 16'h0008; // $26 + $08 = $2e
        mem[16'h0028 >> 1] = 16'h7001; // must be skipped
        mem[16'h002a >> 1] = 16'h4e71;
        mem[16'h002c >> 1] = 16'h4e71;
        mem[16'h002e >> 1] = 16'h7005; // MOVEQ #5,D0
        mem[16'h0030 >> 1] = 16'h4e71;

        // Subroutine: set D1 and return.
        mem[16'h0040 >> 1] = 16'h7203; // MOVEQ #3,D1
        mem[16'h0042 >> 1] = 16'h4e75; // RTS

        repeat (2) @(posedge clk);
        reset_n = 1'b1;

        fork
            begin
                repeat (300) @(posedge clk);
                $fatal(1, "FAIL: M1.8 timeout pc=%h a7=%h", pc, a7);
            end
            begin
                wait (pc == 32'h00000030);
                #1;
                if (d0 !== 32'h00000005)
                    $fatal(1, "FAIL: D0=%h", d0);
                if (dut.dreg[1] !== 32'h00000003)
                    $fatal(1, "FAIL: D1=%h", dut.dreg[1]);
                if (a7 !== 32'h00000200)
                    $fatal(1, "FAIL: A7 not restored: %h", a7);
                if (mem[16'h01fc >> 1] !== 16'h0000 || mem[16'h01fe >> 1] !== 16'h0024)
                    $fatal(1, "FAIL: BSR return frame %h %h", mem[16'h01fc >> 1], mem[16'h01fe >> 1]);
                if (halted || exception)
                    $fatal(1, "FAIL: unexpected halt/exception");
                $display("PASS: M1.8 BSR.w/RTS stack flow and BRA.w");
                $finish;
            end
        join
    end
endmodule
