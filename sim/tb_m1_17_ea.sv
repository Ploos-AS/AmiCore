`timescale 1ns/1ps

module tb_m1_17_ea;
    logic [1:0] mode;
    logic [31:0] address_register;
    logic [15:0] extension_hi;
    logic [15:0] extension_lo;
    logic [31:0] effective_address;
    logic [2:0] extension_bytes;

    amcore_ea dut (
        .mode(mode),
        .address_register(address_register),
        .extension_hi(extension_hi),
        .extension_lo(extension_lo),
        .effective_address(effective_address),
        .extension_bytes(extension_bytes)
    );

    task automatic check(
        input logic [1:0] t_mode,
        input logic [31:0] t_areg,
        input logic [15:0] t_hi,
        input logic [15:0] t_lo,
        input logic [31:0] expected_ea,
        input logic [2:0] expected_bytes
    );
        begin
            mode = t_mode;
            address_register = t_areg;
            extension_hi = t_hi;
            extension_lo = t_lo;
            #1;
            if (effective_address !== expected_ea || extension_bytes !== expected_bytes) begin
                $display("FAIL mode=%0d areg=%08x hi=%04x lo=%04x ea=%08x bytes=%0d expected=%08x/%0d",
                         t_mode, t_areg, t_hi, t_lo, effective_address, extension_bytes,
                         expected_ea, expected_bytes);
                $fatal(1);
            end
        end
    endtask

    initial begin
        check(2'd0, 32'h12345678, 16'h0000, 16'h0000, 32'h12345678, 3'd0);
        check(2'd1, 32'h00001000, 16'h0020, 16'h0000, 32'h00001020, 3'd2);
        check(2'd1, 32'h00001000, 16'hfff0, 16'h0000, 32'h00000ff0, 3'd2);
        check(2'd2, 32'hdeadbeef, 16'h1234, 16'h0000, 32'h00001234, 3'd2);
        check(2'd2, 32'hdeadbeef, 16'h8000, 16'h0000, 32'hffff8000, 3'd2);
        check(2'd3, 32'hdeadbeef, 16'h0012, 16'h3456, 32'h00123456, 3'd4);
        check(2'd3, 32'hdeadbeef, 16'hffff, 16'h8000, 32'hffff8000, 3'd4);

        $display("PASS: M1.17 effective-address generator baseline");
        $finish;
    end
endmodule
