`timescale 1ns/1ps
module tb_m1_11_cpu_ccr;
    logic clk=0,reset_n=0; logic [2:0] irq_level=0;
    logic [31:0] address; logic [15:0] data_out,data_in; logic read,write,ack;
    logic [31:0] d0,pc,a7; logic [15:0] sr; logic halted,exception; logic [7:0] exception_vector;
    logic [15:0] mem [0:255]; integer cycles;
    always #5 clk=~clk;
    assign ack=read|write;
    always_comb data_in=mem[address[8:1]];
    always_ff @(posedge clk) if(write&&ack) mem[address[8:1]]<=data_out;
    amcore_68k_baseline dut(.clk(clk),.reset_n(reset_n),.irq_level(irq_level),.address(address),.data_out(data_out),.data_in(data_in),.read(read),.write(write),.ack(ack),.d0(d0),.pc(pc),.a7(a7),.sr(sr),.halted(halted),.exception(exception),.exception_vector(exception_vector));

    task wait_pc(input [31:0] p); begin
        while(pc!==p) begin @(negedge clk); cycles=cycles+1; if(cycles>300)$fatal(1,"timeout pc=%h wanted=%h",pc,p); end
    end endtask
    task expect_ccr(input ex,en,ez,ev,ec); begin
        if({sr[4],sr[3],sr[2],sr[1],sr[0]}!=={ex,en,ez,ev,ec})
            $fatal(1,"CCR got XNZVC=%b expected=%b",{sr[4:0]},{ex,en,ez,ev,ec});
    end endtask

    initial begin
        integer i; for(i=0;i<256;i=i+1)mem[i]=16'h4e71;
        mem[0]=16'h0000; mem[1]=16'h0200; mem[2]=16'h0000; mem[3]=16'h0020;
        // ADDQ.L #1,D0; NOP; ADDQ.L #1,D0; NOP; SUBQ.L #1,D0; NOP; SUBQ.L #1,D0; NOP
        mem[16]=16'h5280; mem[17]=16'h4e71; mem[18]=16'h5280; mem[19]=16'h4e71;
        mem[20]=16'h5380; mem[21]=16'h4e71; mem[22]=16'h5380; mem[23]=16'h4e71;
        cycles=0; repeat(2)@(posedge clk); reset_n=1;
        wait_pc(32'h20); @(negedge clk); dut.dreg[0]=32'h7fffffff;
        wait_pc(32'h22); expect_ccr(0,1,0,1,0); if(d0!==32'h80000000)$fatal(1,"add overflow result");
        wait_pc(32'h24); @(negedge clk); dut.dreg[0]=32'hffffffff;
        wait_pc(32'h26); expect_ccr(1,0,1,0,1); if(d0!==0)$fatal(1,"add carry result");
        wait_pc(32'h28); @(negedge clk); dut.dreg[0]=32'h80000000;
        wait_pc(32'h2a); expect_ccr(0,0,0,1,0); if(d0!==32'h7fffffff)$fatal(1,"sub overflow result");
        wait_pc(32'h2c); @(negedge clk); dut.dreg[0]=0;
        wait_pc(32'h2e); expect_ccr(1,1,0,0,1); if(d0!==32'hffffffff)$fatal(1,"sub borrow result");
        if(halted||exception)$fatal(1,"unexpected halt/exception");
        $display("PASS: M1.11 CPU-integrated ADDQ.L/SUBQ.L XNZVC semantics"); $finish;
    end
endmodule
