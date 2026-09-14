module tb_m1_7_addressing;
    logic clk=0, reset_n=0;
    logic [31:0] address, d0, pc, a7;
    logic [15:0] data_out, data_in, sr;
    logic read, write, ack, halted, exception;
    logic [7:0] exception_vector;
    logic [15:0] ram [0:511];

    amcore_68k_baseline dut(
        .clk(clk),.reset_n(reset_n),.irq_level(3'd0),.address(address),.data_out(data_out),.data_in(data_in),
        .read(read),.write(write),.ack(ack),.d0(d0),.pc(pc),.a7(a7),.sr(sr),.halted(halted),
        .exception(exception),.exception_vector(exception_vector));

    always #5 clk=~clk;

    always_comb begin
        ack=read|write;
        data_in=16'h4E71;
        if(read) begin
            case(address)
                32'h00000000:data_in=16'h0000;
                32'h00000002:data_in=16'h0200;
                32'h00000004:data_in=16'h0000;
                32'h00000006:data_in=16'h0020;
                32'h00000020:data_in=16'h204F; // MOVEA.L A7,A0
                32'h00000022:data_in=16'h7212; // MOVEQ #$12,D1
                32'h00000024:data_in=16'h2081; // MOVE.L D1,(A0)
                32'h00000026:data_in=16'h4281; // CLR.L D1
                32'h00000028:data_in=16'h2410; // MOVE.L (A0),D2
                32'h0000002A:data_in=16'h2618; // MOVE.L (A0)+,D3
                32'h0000002C:data_in=16'h2102; // MOVE.L D2,-(A0)
                32'h0000002E:data_in=16'h4E71;
                default: begin
                    if(address < 32'h00000400) data_in=ram[address[9:1]];
                    else data_in=16'h4E71;
                end
            endcase
        end
    end

    always_ff @(posedge clk) begin
        if(write && ack && address < 32'h00000400)
            ram[address[9:1]] <= data_out;
    end

    initial begin
        integer i;
        for(i=0;i<512;i=i+1) ram[i]=16'h0000;
        repeat(2) @(posedge clk);
        reset_n=1;
        wait(pc==32'h0000002E);
        #1;
        if(dut.dreg[1]!==32'h00000000) $fatal(1,"FAIL: D1=%h",dut.dreg[1]);
        if(dut.dreg[2]!==32'h00000012) $fatal(1,"FAIL: D2=%h",dut.dreg[2]);
        if(dut.dreg[3]!==32'h00000012) $fatal(1,"FAIL: D3=%h",dut.dreg[3]);
        if(dut.areg[0]!==32'h00000200) $fatal(1,"FAIL: A0=%h",dut.areg[0]);
        if(ram[16'h0100]!==16'h0000 || ram[16'h0101]!==16'h0012)
            $fatal(1,"FAIL: memory=%h_%h",ram[16'h0100],ram[16'h0101]);
        if(halted||exception) $fatal(1,"FAIL: unexpected halt/exception");
        $display("PASS: M1.7 MOVE.L (An)/(An)+/-(An) addressing modes");
        $finish;
    end
endmodule
