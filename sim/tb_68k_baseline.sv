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

    always_comb begin
        data_in = 16'h0000;
        ack = read | write;
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

        wait (d0 == 32'h00000005);
        wait (pc == 32'h00000016);
        #1;
        if (halted) $fatal(1, "FAIL: core halted unexpectedly");
        $display("PASS: 68000 baseline RESET/MOVEQ/BRA/NOP");
        $finish;
    end
endmodule
