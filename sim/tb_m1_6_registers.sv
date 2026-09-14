module tb_m1_6_registers;
    logic clk=0, reset_n=0;
    logic [31:0] address, data_d0, pc, a7;
    logic [15:0] data_out, data_in, sr;
    logic read, write, ack, halted, exception;
    logic [7:0] exception_vector;

    amcore_68k_baseline dut(
        .clk(clk),.reset_n(reset_n),.irq_level(3'd0),.address(address),.data_out(data_out),.data_in(data_in),
        .read(read),.write(write),.ack(ack),.d0(data_d0),.pc(pc),.a7(a7),.sr(sr),.halted(halted),
        .exception(exception),.exception_vector(exception_vector));
    always #5 clk=~clk;
    always_comb begin
        ack=read|write; data_in=16'h4E71;
        case(address)
            32'h0:data_in=16'h0000; 32'h2:data_in=16'h0200;
            32'h4:data_in=16'h0000; 32'h6:data_in=16'h0020;
            32'h20:data_in=16'h7205; // MOVEQ #5,D1
            32'h22:data_in=16'h7400; // MOVEQ #0,D2
            32'h24:data_in=16'h2401; // MOVE.L D1,D2
            32'h26:data_in=16'h5282; // ADDQ.L #1,D2
            32'h28:data_in=16'h4281; // CLR.L D1
            32'h2A:data_in=16'h4E71;
            default:data_in=16'h4E71;
        endcase
    end
    initial begin
        repeat(2) @(posedge clk); reset_n=1;
        wait(pc==32'h2A); #1;
        if(dut.dreg[1]!==32'h0) $fatal(1,"FAIL: D1=%h",dut.dreg[1]);
        if(dut.dreg[2]!==32'h6) $fatal(1,"FAIL: D2=%h",dut.dreg[2]);
        if(data_d0!==32'h0) $fatal(1,"FAIL: D0=%h",data_d0);
        if(a7!==32'h200) $fatal(1,"FAIL: A7=%h",a7);
        if(halted||exception) $fatal(1,"FAIL: unexpected halt/exception");
        $display("PASS: M1.6 D0-D7 register file + MOVE.L/ADDQ/CLR");
        $finish;
    end
endmodule
