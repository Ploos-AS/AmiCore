`timescale 1ns/1ps

module tb_m1_17_lea_pea;
    logic is_pea;
    logic [2:0] destination_areg;
    logic [31:0] effective_address;
    logic write_areg;
    logic [2:0] write_areg_index;
    logic [31:0] write_areg_value;
    logic push_long;
    logic [31:0] push_value;

    amcore_lea_pea dut (
        .is_pea(is_pea),
        .destination_areg(destination_areg),
        .effective_address(effective_address),
        .write_areg(write_areg),
        .write_areg_index(write_areg_index),
        .write_areg_value(write_areg_value),
        .push_long(push_long),
        .push_value(push_value)
    );

    initial begin
        is_pea = 1'b0;
        destination_areg = 3'd5;
        effective_address = 32'h12345678;
        #1;
        if (!write_areg || write_areg_index != 3'd5 ||
            write_areg_value != 32'h12345678 || push_long)
            $fatal(1, "FAIL: LEA primitive");

        is_pea = 1'b1;
        destination_areg = 3'd2;
        effective_address = 32'hffff8000;
        #1;
        if (write_areg || !push_long || push_value != 32'hffff8000)
            $fatal(1, "FAIL: PEA primitive");

        effective_address = 32'h00123456;
        #1;
        if (!push_long || push_value != 32'h00123456)
            $fatal(1, "FAIL: PEA long value");

        $display("PASS: M1.17 LEA/PEA execution primitive");
        $finish;
    end
endmodule
