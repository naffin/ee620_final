module controller_asserts(
   lc3_if.DUT lc3if,
   input logic N, Z, P,
   input logic [15:0] 	   IR,
   input logic	   enaALU, regWE, enaMARM, selMAR, 
   input logic selEAB1, enaPC, ldPC, ldIR, ldMAR,
   input logic  ldMDR, selMDR, flagWE, enaMDR,
   input logic [1:0] aluControl, selPC, selEAB2,
   input logic [2:0] SR1, SR2, DR,
   input logic [5:0] 	  state,
   input logic	  branchEn);

   parameter STATE_fetch0  = 0,  STATE_fetch1 = 1, STATE_fetch2 = 2, STATE_decode = 3;
   parameter STATE_alu0 		= 4;
   parameter STATE_br0 		= 5;
   parameter STATE_jmp0 		= 6;
   parameter STATE_jsr0 		= 7,  STATE_jsr1 = 8;
   parameter STATE_ld0 		= 9,  STATE_ld1 = 10, 	STATE_ld2 = 11;
   parameter STATE_st0 		= 12, STATE_st1 = 13,	 	STATE_st2 = 14;
   parameter STATE_ldi0=15,STATE_ldi1=16,STATE_ldi2=17,STATE_ldi3=18,STATE_ldi4=19;
   parameter STATE_ldr0=20,STATE_ldr1=21,STATE_ldr2=22;
   parameter STATE_lea0=23;
   parameter STATE_sti0=24,STATE_sti1=25,STATE_sti2=26,STATE_sti3=27,STATE_sti4=28;
   parameter STATE_str0=29,STATE_str1=30,STATE_str2=31;
   parameter STATE_trap0 = 32, STATE_trap1 = 33, STATE_trap2 = 34;
   parameter STATE_jsrr0 = 35, STATE_jsrr1 = 36;

endmodule
