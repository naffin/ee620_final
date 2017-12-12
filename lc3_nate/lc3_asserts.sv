//----------------------------------------------------------------------
// This File: lc3_asserts.sv
//----------------------------------------------------------------------
`include "assert_macros.sv"

module lc3_asserts (
	lc3_if.DUT lc3if,
	input enaMARM, enaPC, enaMDR, enaALU,
	  flagWE, ldIR, ldPC, selEAB1,
	  selMAR, regWE,
	input [1:0] selEAB2, selPC,
	input [2:0] DR, SR1, SR2,
	input [1:0] ALUctrl,	
	input N, Z, P, TB,
	input [15:0] eabOut, Ra, Rb, Buss,
	input [15:0] PCOut, ALUOut,
	input [15:0] IR, MARMUXOut, mdrOut,
	input [7:0] zext,
	input selMDR, ldMDR,
	input rst, clk,
	input [15:0] MDR, MAR);

    ERR_RESET_SHOULD_CAUSE_PCOUT0_N0_Z0_P0_IR_0:
		`assert_clk(rst |-> (PCOut==0 && N==0 && Z==1 && P==0 && IR==0));

		
endmodule
