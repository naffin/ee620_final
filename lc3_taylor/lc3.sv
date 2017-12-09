module lc3(lc3_if.DUT lc3if);
   logic [15:0] IR;
   logic 	N, Z, P;
   logic 	enaALU, regWE, enaMARM, selMAR, selEAB1, enaPC, ldPC, ldIR, ldMAR, ldMDR, selMDR, memWE, flagWE, enaMDR;
   logic [1:0] 	aluControl, selPC, selEAB2;
   logic [2:0] 	SR1, SR2, DR;
   
   datapath dp(.*);
   controller fsm(.*);
endmodule
