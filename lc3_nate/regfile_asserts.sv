`include "assert_macros.sv"

module regfile_asserts(
  	input clk,
   	input rst,
   	input writeEN,
   	input [2:0] wrAddr,//=DR
   	input [15:0] wrData, //=Buss
   	input [2:0] rdAddrA,//=SR1
   	input [15:0] rdDataA,//=Ra
   	input [2:0] rdAddrB,//=SR2
   	input [15:0] rdDataB,//=Rb

   	input [15:0] regfile [0:7]);

	ERR_RESET_SHOULD_CAUSE_REGFILE0:
		`assert_clk(rst |-> ##1 regfile[0] == '0 &&
							regfile[1] == '0 &&
							regfile[2] == '0 &&
							regfile[3] == '0 &&
							regfile[4] == '0 &&
							regfile[5] == '0 &&
							regfile[6] == '0 &&
							regfile[7] == '0);

endmodule
