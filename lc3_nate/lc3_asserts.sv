//----------------------------------------------------------------------
// This File: lc3_asserts.sv
//----------------------------------------------------------------------
`include "assert_macros.sv"

module lc3_asserts (
	lc3_if.DUT lc3if,
	input enaMARM, enaPC, enaMDR, enaALU,
	  flagWE, ldIR, ldPC, selEAB1,
	  selMARM, regWE,
	input [1:0] selEAB2, selPC,
	input [2:0] DR, SR1, SR2,
	input [1:0] ALUctrl,	
	input N, Z, P, TB,
	input [15:0] eabOut, Ra, Rb, Buss,
	input [15:0] PCOut, ALUOut,
	input [15:0] IR, MARMUXOut,
	input [15:0] zext,
	input selMDR, ldMDR,
	input rst, clk,
	input [15:0] MDR, MAR);

	ERR_RESET_SHOULD_CAUSE_PCOUT_0_IR_0:
		`assert_clk(rst |-> ##1 PCOut=='0 && IR=='0);
	
	ERR_MORE_THAN_ONE_OF_NZP_IS_HIGH:
		`assert_clk_xrst(3'(N)+3'(P)+3'(Z) <= 1);

	ERR_N_HIGH_AFTER_NEG_BUS_AND_FLAGWE:
		`assert_clk_xrst(16'(signed'(Buss)) < 0 && flagWE |-> ##1 N);

	ERR_N_LOW_AFTER_NON_NEG_BUS_AND_FLAGWE:
		`assert_clk_xrst(16'(signed'(Buss)) >= 0 && flagWE |-> ##1 !N);

	ERR_Z_HIGH_AFTER_ZERO_BUS_AND_FLAGWE:
	  `assert_clk_xrst(Buss == 0 && flagWE |-> ##1 Z);

	ERR_Z_LOW_AFTER_NON_ZERO_BUS_AND_FLAGWE:
	  `assert_clk_xrst(Buss != 0 && flagWE |-> ##1 !Z);

	ERR_P_HIGH_AFTER_POS_BUS_AND_FLAGWE:
	  `assert_clk_xrst(16'(signed'(Buss)) > 0 && flagWE |-> ##1 P);

	ERR_P_LOW_AFTER_NON_POS_BUS_AND_FLAGWE:
	  `assert_clk_xrst(16'(signed'(Buss)) <= 0 && flagWE |-> ##1 !P);

   ERR_ONLY_ONE_TRI_DRIVER_HIGH:
     `assert_clk_xrst(3'(enaALU)+3'(enaMARM)+3'(enaPC)+3'(enaMDR) <= 1);
	
   ERR_BUS_ONLY_TAKES_MARM_WHEN_ENA_MARM:
     `assert_clk_xrst(enaMARM |-> Buss == MARMUXOut);

   ERR_BUS_ONLY_TAKES_PC_WHEN_ENA_PC:
     `assert_clk_xrst(enaPC |-> Buss == PCOut);

   ERR_BUS_ONLY_TAKES_MDR_WHEN_ENA_MDR:
     `assert_clk_xrst(enaMDR |-> Buss == MDR);

   ERR_BUS_ONLY_TAKES_ALU_WHEN_ENA_ALU:
     `assert_clk_xrst(enaALU |-> Buss == ALUOut);

endmodule
