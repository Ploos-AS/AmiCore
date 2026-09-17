// AmiCore M1.17 — minimal clean-room 68000 execution baseline.
// M1.17 integrates LEA/PEA for (An), d16(An), xxx.W and xxx.L control EAs.
module amcore_68k_baseline(
 input logic clk,input logic reset_n,input logic[2:0] irq_level,
 output logic[31:0] address,output logic[15:0] data_out,input logic[15:0] data_in,
 output logic read,output logic write,input logic ack,output logic[31:0] d0,
 output logic[31:0] pc,output logic[31:0] a7,output logic[15:0] sr,
 output logic halted,output logic exception,output logic[7:0] exception_vector);
 typedef enum logic[5:0]{S_RESET_SSP_HI,S_RESET_SSP_LO,S_RESET_PC_HI,S_RESET_PC_LO,S_FETCH,S_EXEC,S_IMM_SR,S_BRANCH_EXT,S_BSR_PUSH_LO,S_BSR_PUSH_HI,S_RTS_POP_HI,S_RTS_POP_LO,S_EXC_PUSH_PC_LO,S_EXC_PUSH_PC_HI,S_EXC_PUSH_SR,S_EXC_VEC_HI,S_EXC_VEC_LO,S_RTE_POP_SR,S_RTE_POP_PC_HI,S_RTE_POP_PC_LO,S_MEM_RD_HI,S_MEM_RD_LO,S_MEM_WR_HI,S_MEM_WR_LO,S_HALT,S_DBCC_EXT,S_JUMP_EXT_W,S_JUMP_EXT_HI,S_JUMP_EXT_LO,S_EA_EXT_W,S_EA_EXT_HI,S_EA_EXT_LO}state_t;
 state_t state; logic[31:0]dreg[0:7],areg[0:7],usp,ssp; logic[15:0]ir,reset_hi,vector_hi,rte_pc_hi,rts_pc_hi,rte_sr,jump_hi,ea_hi; logic[31:0]exception_pc;logic[15:0]exception_sr;logic[3:0]quick_value;logic irq_pending;logic[31:0]alu_result;logic[32:0]alu_wide;logic alu_x,alu_n,alu_z,alu_v,alu_c;logic[31:0]mem_ea,mem_value,ea_base;logic[2:0]mem_dreg,mem_areg,ea_dest_areg;logic[1:0]mem_update;logic branch_is_bsr,branch_take,jump_is_jsr,jump_is_pc_relative,jump_is_indexed,ea_is_pea,ea_is_absw,ea_is_indexed;logic[31:0]branch_return;logic[31:0]indexed_value;integer i;
 localparam logic[1:0] MEM_NO_UPDATE=0,MEM_POSTINC=1,MEM_PREDEC=2; assign d0=dreg[0];assign a7=areg[7];
 function automatic logic bcc_condition(input logic[3:0]cc);begin case(cc)
  4'h0:bcc_condition=1'b1; 4'h1:bcc_condition=1'b0;
  4'h2:bcc_condition=!sr[0]&&!sr[2]; 4'h3:bcc_condition=sr[0]||sr[2];
  4'h4:bcc_condition=!sr[0]; 4'h5:bcc_condition=sr[0];
  4'h6:bcc_condition=!sr[2]; 4'h7:bcc_condition=sr[2];
  4'h8:bcc_condition=!sr[1]; 4'h9:bcc_condition=sr[1];
  4'ha:bcc_condition=!sr[3]; 4'hb:bcc_condition=sr[3];
  4'hc:bcc_condition=(sr[3]==sr[1]); 4'hd:bcc_condition=(sr[3]!=sr[1]);
  4'he:bcc_condition=!sr[2]&&(sr[3]==sr[1]); 4'hf:bcc_condition=sr[2]||(sr[3]!=sr[1]);
 endcase end endfunction
 always_comb begin
  indexed_value=data_in[15]?areg[data_in[14:12]]:dreg[data_in[14:12]];
  address=0;data_out=0;read=0;write=0;quick_value=(ir[11:9]==0)?8:{1'b0,ir[11:9]};irq_pending=(irq_level!=0)&&((irq_level==7)||(irq_level>sr[10:8]));alu_result=dreg[ir[2:0]];alu_wide={1'b0,dreg[ir[2:0]]};alu_x=0;alu_n=0;alu_z=0;alu_v=0;alu_c=0;
  if((ir&16'hF1F8)==16'h5080)begin alu_wide={1'b0,dreg[ir[2:0]]}+{29'd0,quick_value};alu_result=alu_wide[31:0];alu_c=alu_wide[32];alu_x=alu_c;alu_v=~dreg[ir[2:0]][31]&alu_result[31];alu_n=alu_result[31];alu_z=(alu_result==0);end
  else if((ir&16'hF1F8)==16'h5180)begin alu_result=dreg[ir[2:0]]-{28'd0,quick_value};alu_c=(dreg[ir[2:0]]<{28'd0,quick_value});alu_x=alu_c;alu_v=dreg[ir[2:0]][31]&~alu_result[31];alu_n=alu_result[31];alu_z=(alu_result==0);end
  case(state)
   S_RESET_SSP_HI:begin address=0;read=1;end S_RESET_SSP_LO:begin address=2;read=1;end S_RESET_PC_HI:begin address=4;read=1;end S_RESET_PC_LO:begin address=6;read=1;end S_FETCH:if(!irq_pending)begin address=pc;read=1;end S_IMM_SR,S_BRANCH_EXT,S_DBCC_EXT,S_JUMP_EXT_W,S_JUMP_EXT_HI,S_EA_EXT_W,S_EA_EXT_HI:begin address=pc+2;read=1;end S_JUMP_EXT_LO,S_EA_EXT_LO:begin address=pc+4;read=1;end
   S_BSR_PUSH_LO:begin address=areg[7]-2;data_out=branch_return[15:0];write=1;end S_BSR_PUSH_HI:begin address=areg[7]-2;data_out=branch_return[31:16];write=1;end S_RTS_POP_HI,S_RTS_POP_LO:begin address=areg[7];read=1;end
   S_EXC_PUSH_PC_LO:begin address=areg[7]-2;data_out=exception_pc[15:0];write=1;end S_EXC_PUSH_PC_HI:begin address=areg[7]-2;data_out=exception_pc[31:16];write=1;end S_EXC_PUSH_SR:begin address=areg[7]-2;data_out=exception_sr;write=1;end S_EXC_VEC_HI:begin address={22'h0,exception_vector,2'b00};read=1;end S_EXC_VEC_LO:begin address={22'h0,exception_vector,2'b00}+2;read=1;end
   S_RTE_POP_SR,S_RTE_POP_PC_HI,S_RTE_POP_PC_LO:begin address=areg[7];read=1;end S_MEM_RD_HI:begin address=mem_ea;read=1;end S_MEM_RD_LO:begin address=mem_ea+2;read=1;end S_MEM_WR_HI:begin address=mem_ea;data_out=mem_value[31:16];write=1;end S_MEM_WR_LO:begin address=mem_ea+2;data_out=mem_value[15:0];write=1;end default:begin end endcase
 end
 task automatic enter_exception(input[7:0]vec);begin exception<=1;exception_vector<=vec;exception_pc<=pc;exception_sr<=sr;if(!sr[13])begin usp<=areg[7];areg[7]<=ssp;end sr[13]<=1;state<=S_EXC_PUSH_PC_LO;end endtask
 always_ff@(posedge clk)begin
  if(!reset_n)begin state<=S_RESET_SSP_HI;reset_hi<=0;vector_hi<=0;rte_pc_hi<=0;rts_pc_hi<=0;rte_sr<=16'h2700;exception_pc<=0;exception_sr<=0;pc<=0;sr<=16'h2700;ir<=0;halted<=0;exception<=0;exception_vector<=0;usp<=0;ssp<=0;mem_ea<=0;mem_value<=0;mem_dreg<=0;mem_areg<=0;mem_update<=0;branch_is_bsr<=0;branch_take<=0;branch_return<=0;jump_hi<=0;jump_is_jsr<=0;jump_is_pc_relative<=0;jump_is_indexed<=0;ea_hi<=0;ea_base<=0;ea_dest_areg<=0;ea_is_pea<=0;ea_is_absw<=0;ea_is_indexed<=0;for(i=0;i<8;i=i+1)begin dreg[i]<=0;areg[i]<=0;end end
  else case(state)
   S_RESET_SSP_HI:if(ack)begin reset_hi<=data_in;state<=S_RESET_SSP_LO;end S_RESET_SSP_LO:if(ack)begin areg[7]<={reset_hi,data_in};ssp<={reset_hi,data_in};state<=S_RESET_PC_HI;end S_RESET_PC_HI:if(ack)begin reset_hi<=data_in;state<=S_RESET_PC_LO;end S_RESET_PC_LO:if(ack)begin pc<={reset_hi,data_in};state<=S_FETCH;end
   S_FETCH:begin if(irq_pending)begin enter_exception(8'd24+{5'd0,irq_level});sr[10:8]<=irq_level;end else if(ack)begin ir<=data_in;state<=S_EXEC;end end
   S_EXEC:begin
    if(ir==16'h4E71)begin pc<=pc+2;state<=S_FETCH;end
    else if((ir&16'hF100)==16'h7000)begin dreg[ir[11:9]]<={{24{ir[7]}},ir[7:0]};sr[3]<=ir[7];sr[2]<=(ir[7:0]==0);sr[1:0]<=0;pc<=pc+2;state<=S_FETCH;end
    else if((ir&16'hF0F8)==16'h50C8)begin branch_take<=bcc_condition(ir[11:8]);state<=S_DBCC_EXT;end
    else if((ir&16'hF0F8)==16'h50C0)begin dreg[ir[2:0]]<={dreg[ir[2:0]][31:8],bcc_condition(ir[11:8])?8'hff:8'h00};pc<=pc+2;state<=S_FETCH;end
    else if((ir&16'hFF00)==16'h6100)begin branch_is_bsr<=1;branch_take<=1;if(ir[7:0]!=0)begin branch_return<=pc+2;pc<=pc+2+{{24{ir[7]}},ir[7:0]};state<=S_BSR_PUSH_LO;end else state<=S_BRANCH_EXT;end
    else if((ir&16'hFF00)==16'h6000)begin branch_is_bsr<=0;branch_take<=1;if(ir[7:0]!=0)begin pc<=pc+2+{{24{ir[7]}},ir[7:0]};state<=S_FETCH;end else state<=S_BRANCH_EXT;end
    else if(ir[15:12]==4'h6)begin branch_is_bsr<=0;branch_take<=bcc_condition(ir[11:8]);if(ir[7:0]!=0)begin if(bcc_condition(ir[11:8]))pc<=pc+2+{{24{ir[7]}},ir[7:0]};else pc<=pc+2;state<=S_FETCH;end else state<=S_BRANCH_EXT;end
    else if((ir&16'hF1F8)==16'h5080||(ir&16'hF1F8)==16'h5180)begin dreg[ir[2:0]]<=alu_result;sr[4]<=alu_x;sr[3]<=alu_n;sr[2]<=alu_z;sr[1]<=alu_v;sr[0]<=alu_c;pc<=pc+2;state<=S_FETCH;end
    else if((ir&16'hFFF8)==16'h4280)begin dreg[ir[2:0]]<=0;sr[3]<=0;sr[2]<=1;sr[1:0]<=0;pc<=pc+2;state<=S_FETCH;end
    else if(ir[15:12]==2&&ir[8:6]==0&&ir[5:3]==0)begin dreg[ir[11:9]]<=dreg[ir[2:0]];sr[3]<=dreg[ir[2:0]][31];sr[2]<=(dreg[ir[2:0]]==0);sr[1:0]<=0;pc<=pc+2;state<=S_FETCH;end
    else if(ir[15:12]==2&&ir[8:6]==1&&ir[5:3]==1)begin areg[ir[11:9]]<=areg[ir[2:0]];pc<=pc+2;state<=S_FETCH;end
    else if((ir&16'hFFF8)==16'h4E60)begin if(sr[13])begin usp<=areg[ir[2:0]];pc<=pc+2;state<=S_FETCH;end else enter_exception(8);end
    else if((ir&16'hFFF8)==16'h4E68)begin if(sr[13])begin areg[ir[2:0]]<=usp;pc<=pc+2;state<=S_FETCH;end else enter_exception(8);end
    else if((ir&16'hF1F8)==16'h41D0)begin areg[ir[11:9]]<=areg[ir[2:0]];pc<=pc+2;state<=S_FETCH;end
    else if((ir&16'hF1F8)==16'h41E8)begin ea_is_pea<=0;ea_is_absw<=0;ea_dest_areg<=ir[11:9];ea_base<=areg[ir[2:0]];state<=S_EA_EXT_W;end
    else if((ir&16'hF1F8)==16'h41F0)begin ea_is_pea<=0;ea_is_absw<=0;ea_is_indexed<=1;ea_dest_areg<=ir[11:9];ea_base<=areg[ir[2:0]];state<=S_EA_EXT_W;end
    else if((ir&16'hF1FF)==16'h41FB)begin ea_is_pea<=0;ea_is_absw<=0;ea_is_indexed<=1;ea_dest_areg<=ir[11:9];ea_base<=pc+2;state<=S_EA_EXT_W;end
    else if((ir&16'hF1FF)==16'h41FA)begin ea_is_pea<=0;ea_is_absw<=0;ea_dest_areg<=ir[11:9];ea_base<=pc+2;state<=S_EA_EXT_W;end
    else if((ir&16'hF1FF)==16'h41F8)begin ea_is_pea<=0;ea_is_absw<=1;ea_dest_areg<=ir[11:9];ea_base<=0;state<=S_EA_EXT_W;end
    else if((ir&16'hF1FF)==16'h41F9)begin ea_is_pea<=0;ea_dest_areg<=ir[11:9];state<=S_EA_EXT_HI;end
    else if((ir&16'hFFF8)==16'h4850)begin branch_return<=areg[ir[2:0]];pc<=pc+2;state<=S_BSR_PUSH_LO;end
    else if((ir&16'hFFF8)==16'h4870)begin ea_is_pea<=1;ea_is_absw<=0;ea_is_indexed<=1;ea_base<=areg[ir[2:0]];state<=S_EA_EXT_W;end
    else if(ir==16'h487B)begin ea_is_pea<=1;ea_is_absw<=0;ea_is_indexed<=1;ea_base<=pc+2;state<=S_EA_EXT_W;end
    else if((ir&16'hFFF8)==16'h4868)begin ea_is_pea<=1;ea_is_absw<=0;ea_base<=areg[ir[2:0]];state<=S_EA_EXT_W;end
    else if(ir==16'h487A)begin ea_is_pea<=1;ea_is_absw<=0;ea_base<=pc+2;state<=S_EA_EXT_W;end
    else if(ir==16'h4878)begin ea_is_pea<=1;ea_is_absw<=1;ea_base<=0;state<=S_EA_EXT_W;end
    else if(ir==16'h4879)begin ea_is_pea<=1;state<=S_EA_EXT_HI;end
    else if((ir&16'hFFF8)==16'h4ED0)begin pc<=areg[ir[2:0]];state<=S_FETCH;end
    else if((ir&16'hFFF8)==16'h4E90)begin branch_return<=pc+2;pc<=areg[ir[2:0]];state<=S_BSR_PUSH_LO;end
    else if((ir&16'hFFF8)==16'h4EF0||(ir&16'hFFF8)==16'h4EB0)begin jump_is_jsr<=((ir&16'hFFF8)==16'h4EB0);jump_is_pc_relative<=0;jump_is_indexed<=1;ea_base<=areg[ir[2:0]];state<=S_JUMP_EXT_W;end
    else if(ir==16'h4EFB||ir==16'h4EBB)begin jump_is_jsr<=(ir==16'h4EBB);jump_is_pc_relative<=1;jump_is_indexed<=1;ea_base<=pc+2;state<=S_JUMP_EXT_W;end
    else if(ir==16'h4EFA||ir==16'h4EBA)begin jump_is_jsr<=(ir==16'h4EBA);jump_is_pc_relative<=1;state<=S_JUMP_EXT_W;end
    else if(ir==16'h4EF8||ir==16'h4EB8)begin jump_is_jsr<=(ir==16'h4EB8);jump_is_pc_relative<=0;state<=S_JUMP_EXT_W;end
    else if(ir==16'h4EF9||ir==16'h4EB9)begin jump_is_jsr<=(ir==16'h4EB9);jump_is_pc_relative<=0;state<=S_JUMP_EXT_HI;end
    else if(ir[15:12]==2&&ir[8:6]==0&&(ir[5:3]==2||ir[5:3]==3||ir[5:3]==4))begin mem_dreg<=ir[11:9];mem_areg<=ir[2:0];mem_update<=0;if(ir[5:3]==4)begin mem_ea<=areg[ir[2:0]]-4;areg[ir[2:0]]<=areg[ir[2:0]]-4;mem_update<=2;end else begin mem_ea<=areg[ir[2:0]];if(ir[5:3]==3)mem_update<=1;end state<=S_MEM_RD_HI;end
    else if(ir[15:12]==2&&ir[5:3]==0&&(ir[8:6]==2||ir[8:6]==3||ir[8:6]==4))begin mem_value<=dreg[ir[2:0]];mem_areg<=ir[11:9];mem_update<=0;sr[3]<=dreg[ir[2:0]][31];sr[2]<=(dreg[ir[2:0]]==0);sr[1:0]<=0;if(ir[8:6]==4)begin mem_ea<=areg[ir[11:9]]-4;areg[ir[11:9]]<=areg[ir[11:9]]-4;mem_update<=2;end else begin mem_ea<=areg[ir[11:9]];if(ir[8:6]==3)mem_update<=1;end state<=S_MEM_WR_HI;end
    else if(ir==16'h4E75)state<=S_RTS_POP_HI;else if(ir==16'h46FC)begin if(sr[13])state<=S_IMM_SR;else enter_exception(8);end else if(ir==16'h4E73)begin if(sr[13])state<=S_RTE_POP_SR;else enter_exception(8);end else enter_exception(4);
   end
   S_EA_EXT_W:if(ack)begin if(ea_is_absw)branch_return<={{16{data_in[15]}},data_in};else if(ea_is_indexed)branch_return<=ea_base+{{24{data_in[7]}},data_in[7:0]}+(data_in[11]?indexed_value:{{16{indexed_value[15]}},indexed_value[15:0]});else branch_return<=ea_base+{{16{data_in[15]}},data_in};if(ea_is_pea)begin pc<=pc+4;state<=S_BSR_PUSH_LO;end else begin if(ea_is_absw)areg[ea_dest_areg]<={{16{data_in[15]}},data_in};else areg[ea_dest_areg]<=ea_base+{{16{data_in[15]}},data_in};pc<=pc+4;state<=S_FETCH;end end
   S_EA_EXT_HI:if(ack)begin ea_hi<=data_in;state<=S_EA_EXT_LO;end
   S_EA_EXT_LO:if(ack)begin branch_return<={ea_hi,data_in};if(ea_is_pea)begin pc<=pc+6;state<=S_BSR_PUSH_LO;end else begin areg[ea_dest_areg]<={ea_hi,data_in};pc<=pc+6;state<=S_FETCH;end end
   S_JUMP_EXT_W:if(ack)begin if(jump_is_jsr)begin branch_return<=pc+4;if(jump_is_pc_relative)pc<=pc+2+{{16{data_in[15]}},data_in};else pc<={{16{data_in[15]}},data_in};state<=S_BSR_PUSH_LO;end else begin if(jump_is_pc_relative)pc<=pc+2+{{16{data_in[15]}},data_in};else pc<={{16{data_in[15]}},data_in};state<=S_FETCH;end end
   S_JUMP_EXT_HI:if(ack)begin jump_hi<=data_in;state<=S_JUMP_EXT_LO;end
   S_JUMP_EXT_LO:if(ack)begin if(jump_is_jsr)begin branch_return<=pc+6;pc<={jump_hi,data_in};state<=S_BSR_PUSH_LO;end else begin pc<={jump_hi,data_in};state<=S_FETCH;end end
   S_DBCC_EXT:if(ack)begin if(branch_take)pc<=pc+4;else begin dreg[ir[2:0]]<={dreg[ir[2:0]][31:16],dreg[ir[2:0]][15:0]-16'd1};if((dreg[ir[2:0]][15:0]-16'd1)!=16'hffff)pc<=pc+2+{{16{data_in[15]}},data_in};else pc<=pc+4;end state<=S_FETCH;end
   S_BRANCH_EXT:if(ack)begin if(branch_is_bsr)begin branch_return<=pc+4;pc<=pc+2+{{16{data_in[15]}},data_in};state<=S_BSR_PUSH_LO;end else begin if(branch_take)pc<=pc+2+{{16{data_in[15]}},data_in};else pc<=pc+4;state<=S_FETCH;end end
   S_BSR_PUSH_LO:if(ack)begin areg[7]<=areg[7]-2;state<=S_BSR_PUSH_HI;end S_BSR_PUSH_HI:if(ack)begin areg[7]<=areg[7]-2;state<=S_FETCH;end S_RTS_POP_HI:if(ack)begin rts_pc_hi<=data_in;areg[7]<=areg[7]+2;state<=S_RTS_POP_LO;end S_RTS_POP_LO:if(ack)begin pc<={rts_pc_hi,data_in};areg[7]<=areg[7]+2;state<=S_FETCH;end
   S_MEM_RD_HI:if(ack)begin mem_value[31:16]<=data_in;state<=S_MEM_RD_LO;end S_MEM_RD_LO:if(ack)begin mem_value[15:0]<=data_in;dreg[mem_dreg]<={mem_value[31:16],data_in};sr[3]<=mem_value[31];sr[2]<=({mem_value[31:16],data_in}==0);sr[1:0]<=0;if(mem_update==1)areg[mem_areg]<=areg[mem_areg]+4;pc<=pc+2;state<=S_FETCH;end S_MEM_WR_HI:if(ack)state<=S_MEM_WR_LO;S_MEM_WR_LO:if(ack)begin if(mem_update==1)areg[mem_areg]<=areg[mem_areg]+4;pc<=pc+2;state<=S_FETCH;end
   S_IMM_SR:if(ack)begin if(sr[13]&&!data_in[13])begin ssp<=areg[7];areg[7]<=usp;end sr<=data_in;pc<=pc+4;state<=S_FETCH;end
   S_EXC_PUSH_PC_LO:if(ack)begin areg[7]<=areg[7]-2;state<=S_EXC_PUSH_PC_HI;end S_EXC_PUSH_PC_HI:if(ack)begin areg[7]<=areg[7]-2;state<=S_EXC_PUSH_SR;end S_EXC_PUSH_SR:if(ack)begin areg[7]<=areg[7]-2;state<=S_EXC_VEC_HI;end S_EXC_VEC_HI:if(ack)begin vector_hi<=data_in;state<=S_EXC_VEC_LO;end S_EXC_VEC_LO:if(ack)begin pc<={vector_hi,data_in};exception<=0;state<=S_FETCH;end
   S_RTE_POP_SR:if(ack)begin rte_sr<=data_in;areg[7]<=areg[7]+2;state<=S_RTE_POP_PC_HI;end S_RTE_POP_PC_HI:if(ack)begin rte_pc_hi<=data_in;areg[7]<=areg[7]+2;state<=S_RTE_POP_PC_LO;end S_RTE_POP_PC_LO:if(ack)begin pc<={rte_pc_hi,data_in};sr<=rte_sr;if(!rte_sr[13])begin ssp<=areg[7]+2;areg[7]<=usp;end else begin areg[7]<=areg[7]+2;ssp<=areg[7]+2;end exception<=0;state<=S_FETCH;end
   default:state<=S_HALT;
  endcase
 end
endmodule