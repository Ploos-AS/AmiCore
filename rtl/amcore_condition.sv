// AmiCore M1.15 — clean-room 68000 condition-code helper.
// Provides the shared condition truth table used by Bcc, DBcc and Scc.
module amcore_condition(
 input  logic [3:0] cc,
 input  logic       n,
 input  logic       z,
 input  logic       v,
 input  logic       c,
 output logic       take,
 output logic [7:0] scc_value
);
 always_comb begin
  case (cc)
   4'h0: take = 1'b1;              // T
   4'h1: take = 1'b0;              // F
   4'h2: take = !c && !z;          // HI
   4'h3: take = c || z;            // LS
   4'h4: take = !c;                // CC
   4'h5: take = c;                 // CS
   4'h6: take = !z;                // NE
   4'h7: take = z;                 // EQ
   4'h8: take = !v;                // VC
   4'h9: take = v;                 // VS
   4'ha: take = !n;                // PL
   4'hb: take = n;                 // MI
   4'hc: take = (n == v);          // GE
   4'hd: take = (n != v);          // LT
   4'he: take = !z && (n == v);    // GT
   4'hf: take = z || (n != v);     // LE
   default: take = 1'b0;
  endcase
  scc_value = take ? 8'hff : 8'h00;
 end
endmodule
