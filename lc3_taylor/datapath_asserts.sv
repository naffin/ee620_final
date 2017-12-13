module datapath_asserts(
   lc3_if.DUT lc3if,
   input logic selEAB1,enaALU,regWE,flagWE,enaMARM,
   input logic selMAR,enaPC,ldPC,ldIR,ldMAR,
   input logic ldMDR,selMDR,enaMDR,
   input logic [1:0] aluControl,selPC,selEAB2,
   input logic [2:0] SR1,SR2,DR,
   input logic N,Z,P,
   input logic [15:0] IR,
   input logic [15:0] 	       bus,
   input logic [15:0]        PC,alu_out,alu_operand_2,eab_op_1,eab_op_2,MARM_out,
   input logic [15:0]        SR1_out,SR2_out,eab_out,
   input logic [15:0]        reg_file [0:7],
   input logic [2:0] 	       nzp,
   input logic [15:0] MAR,MDR);
`include "assert_macros.sv"

//====== reset assertions Nate added ========
   ERR_RESET_SHOULD_CAUSE_PC_0_IR_0_REGFILE_0:
      `assert_clk(rst |-> ##1 PC=='0 && IR=='0 &&
      						  reg_file[0] == '0 &&
							  reg_file[1] == '0 &&
							  reg_file[2] == '0 &&
							  reg_file[3] == '0 &&
							  reg_file[4] == '0 &&
							  reg_file[5] == '0 &&
							  reg_file[6] == '0 &&
							  reg_file[7] == '0);

//====== end of what Nate added =============

   ERR_N_HIGH_AFTER_NEG_BUS_AND_FLAGWE:
     `assert_clk_xrst(16'(signed'(bus)) < 0 && flagWE |-> ##1 N);
   ERR_N_LOW_AFTER_NON_NEG_BUS_AND_FLAGWE:
     `assert_clk_xrst(16'(signed'(bus)) >= 0 && flagWE |-> ##1 !N);
   ERR_Z_HIGH_AFTER_ZERO_BUS_AND_FLAGWE:
     `assert_clk_xrst(bus == 0 && flagWE |-> ##1 Z);
   ERR_Z_LOW_AFTER_NON_ZERO_BUS_AND_FLAGWE:
     `assert_clk_xrst(bus != 0 && flagWE |-> ##1 !Z);
   ERR_P_HIGH_AFTER_POS_BUS_AND_FLAGWE:
     `assert_clk_xrst(16'(signed'(bus)) > 0 && flagWE |-> ##1 P);
   ERR_P_LOW_AFTER_NON_POS_BUS_AND_FLAGWE:
     `assert_clk_xrst(16'(signed'(bus)) <= 0 && flagWE |-> ##1 !P);
   ERR_ONLY_ONE_NZP_HIGH:
     `assert_clk_xrst(3'(N)+3'(P)+3'(Z) <= 1);
   ERR_ONLY_ONE_TRI_DRIVER_HIGH:
     `assert_clk_xrst(3'(enaALU)+3'(enaMARM)+3'(enaPC)+3'(enaMDR) <= 1);
   ERR_BUS_ONLY_TAKES_MARM_WHEN_ENA_MARM:
     `assert_clk_xrst(enaMARM |-> bus == MARM_out);
   ERR_BUS_ONLY_TAKES_PC_WHEN_ENA_PC:
     `assert_clk_xrst(enaPC |-> bus == PC);
   ERR_BUS_ONLY_TAKES_MDR_WHEN_ENA_MDR:
     `assert_clk_xrst(enaMDR |-> bus == MDR);
   ERR_BUS_ONLY_TAKES_ALU_WHEN_ENA_ALU:
     `assert_clk_xrst(enaALU |-> bus == alu_out);

endmodule
