module tb_68k_baseline;
    logic clk = 1'b0;
    logic reset_n = 1'b0;
    logic [31:0] address;
    logic [15:0] data_out, data_in;
    logic read, write, ack;
    logic [31:0] d0, pc;
    logic halted;

    logic [15:0] mem [0:7];

    amcore_68k_baseline dut (
        .clk(clk), .reset_n(reset_n), .irq_level(3'd0), .address(address), .data_out(data_out),
        .data_in(data_in), .read(read), .write(write), .ack(ack),
        .d0(d0), .pc(pc), .halted(halted)
    );

    always #5 clk = ~clk;

    // Use continuous acknowledge. Making ack combinationally depend on the
    // DUT's read/write outputs creates an unnecessary zero-time feedback path
    // through the core's combinational bus logic under Icarus.
    assign ack = 1'b1;

    always_comb begin
        data_in = 16'h0000;
        if (read) begin
            case (address)
                32'h00000000: data_in = 16'h0000;
                32'h00000002: data_in = 16'h0100;
                32'h00000004: data_in = 16'h0000;
                32'h00000006: data_in = 16'h0010;
                32'h00000010: data_in = mem[0];
                32'h00000012: data_in = mem[1];
                32'h00000014: data_in = mem[2];
                default: data_in = 16'h4E71;
            endcase
        end
    end

    initial begin
        mem[0] = 16'h7005;
        mem[1] = 16'h6002;
        mem[2] = 16'h4E71;

        // The core uses a synchronous active-low reset. Keep reset asserted
        // across clock edges so state/register initialization is guaranteed.
        repeat (2) @(posedge clk);
        reset_n = 1'b1;

        // Bound the smoke test in simulated cycles rather than waiting
        // indefinitely for architectural state. This also makes failures
        // report the state that was actually reached.
        begin : baseline_watchdog
            integer cycles;
            logic saw_moveq;
            logic saw_branch_target;
            saw_moveq = 1'b0;
            saw_branch_target = 1'b0;
            for (cycles = 0; cycles < 100; cycles = cycles + 1) begin
                @(posedge clk);
                #1;
                if (d0 == 32'h00000005) saw_moveq = 1'b1;
                if (pc == 32'h00000016) saw_branch_target = 1'b1;
                if (halted) $fatal(1, "FAIL: core halted unexpectedly at pc=%08x", pc);
                if (saw_moveq && saw_branch_target) begin
                    $display("PASS: 68000 baseline RESET/MOVEQ/BRA/NOP");
                    $finish;
                end
            end
            $fatal(1, "FAIL: baseline did not converge: pc=%08x d0=%08x moveq=%0d branch=%0d",
                   pc, d0, saw_moveq, saw_branch_target);
        end
    end
endmodule
