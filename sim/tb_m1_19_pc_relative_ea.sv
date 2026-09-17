`timescale 1ns/1ps

module tb_m1_19_pc_relative_ea;
    logic [2:0] mode;
    logic [31:0] address_register;
    logic [31:0] pc_base;
    logic [15:0] extension_hi;
    logic [15:0] extension_lo;
    logic [31:0] index_register;
    logic [31:0] effective_address;
    logic [2:0] extension_bytes;

    amcore_ea dut (
        .mode(mode),
        .address_register(address_register),
        .pc_base(pc_base),
        .extension_hi(extension_hi),
        .extension_lo(extension_lo),
        .index_register(index_register),
        .effective_address(effective_address),
        .extension_bytes(extension_bytes)
    );

    task automatic check_pc_relative(
        input logic [31:0] t_pc_base,
        input logic [15:0] t_disp,
        input logic [31:0] expected_ea
    );
        begin
            mode = 3'd4;
            address_register = 32'hdeadbeef;
            pc_base = t_pc_base;
            extension_hi = t_disp;
            extension_lo = 16'h0000;
            #1;
            if (effective_address !== expected_ea || extension_bytes !== 3'd2) begin
                $display("FAIL pc=%08x disp=%04x ea=%08x bytes=%0d expected=%08x/2",
                         t_pc_base, t_disp, effective_address, extension_bytes, expected_ea);
                $fatal(1);
            end
        end
    endtask

    initial begin
        index_register = 32'd0;
        check_pc_relative(32'h00000102, 16'h001e, 32'h00000120);
        check_pc_relative(32'h00000120, 16'hffe0, 32'h00000100);
        check_pc_relative(32'h00ffff00, 16'h0100, 32'h01000000);
        check_pc_relative(32'h01000000, 16'h8000, 32'h00ff8000);
        $display("PASS: M1.19 d16(PC) effective-address primitive");
        $finish;
    end
endmodule
