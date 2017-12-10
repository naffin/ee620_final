module datapath(lc3if,selEAB1,enaALU,regWE,flagWE,enaMARM,
		selMAR,enaPC,ldPC,ldIR,ldMAR,
		ldMDR,selMDR,enaMDR,
		aluControl,selPC,selEAB2,
		SR1,SR2,DR,N,Z,P,IR);
   lc3_if.DUT lc3if;
   input selEAB1,enaALU,regWE,flagWE,enaMARM;
   input selMAR,enaPC,ldPC,ldIR,ldMAR;
   input ldMDR,selMDR,enaMDR;
   input [1:0] aluControl,selPC,selEAB2;
   input [2:0] SR1,SR2,DR;
   output logic N,Z,P;
   output logic [15:0] IR;

   wire [15:0] 	       bus;
   
   logic [15:0]        PC,alu_out,alu_operand_2,eab_op_1,eab_op_2,MARM_out;
   logic [15:0]        SR1_out,SR2_out,eab_out;
   logic [15:0]        reg_file [0:7];
   logic [2:0] 	       nzp;
   logic [15:0] MAR,MDR;
   integer    i;
       

   always@(posedge lc3if.clk) begin
     if(lc3if.rst)
       MAR <= 0;
     else if(ldMAR)
       MAR <= bus;
   end

   always@(posedge lc3if.clk)
     if(lc3if.rst)
       MDR <= 0;
     else if(ldMDR) begin
	if(selMDR)
	  MDR <= lc3if.data_out;
	else
	  MDR <= bus;
     end

   assign lc3if.addr = MAR;
   assign lc3if.data_in = MDR;
   assign lc3if.ldMAR = ldMAR;
   
   assign bus = (enaMDR)?MDR:'z;
   assign bus = (enaPC)?PC:'z;
   assign bus = (enaALU)?alu_out:'z;
   assign bus = (enaMARM)?MARM_out:'z;

   always_comb begin
      alu_operand_2 = (IR[5])?16'(signed'(IR[4:0])):SR2_out;
      alu_out = (IR[15:14] == 0)? SR1_out + alu_operand_2 :
   		(IR[15:14] == 1)? SR1_out & alu_operand_2 :
   		~SR1_out;
      MARM_out = (selMAR)?IR[7:0]:eab_out;
      N = nzp[2];
      Z = nzp[1];
      P = nzp[0];
      eab_op_1 = (selEAB1)?SR1_out:PC;
      eab_op_2 = (selEAB2 == 0)?0:
		 (selEAB2 == 1)?16'(signed'(IR[5:0])):
		 (selEAB2 == 2)?16'(signed'(IR[8:0])):
		 16'(signed'(IR[10:0]));
   end

   always_comb begin
      eab_out = eab_op_1 + eab_op_2;
      SR1_out = reg_file[SR1];
      SR2_out = reg_file[SR2];
   end
   
   always@(posedge lc3if.clk) begin
      if(lc3if.rst) 
	PC <= 0;
      else if(ldPC) begin
	 if(selPC === 0)
	   PC <= PC +1;
	 else if(selPC === 1)
	   PC <= eab_out;
	 else if(selPC === 2)
	   PC <= bus;
      end
   end

   always@(posedge lc3if.clk) begin
      if(lc3if.rst) begin
	 nzp <= 0;
      end
      else if(flagWE) begin
	 if($signed(bus) < 0) 
	   nzp <= 3'b100;
	 else if($signed(bus) == 0) 
	   nzp <= 3'b010;
	 else
	   nzp <= 3'b001;
      end
   end 
   
   always@(posedge lc3if.clk) begin
      if(lc3if.rst)
	for(int i = 0; i < 8; i++)
	  reg_file[i] <= 0;
      else if(regWE)
	reg_file[DR] <= bus;
   end
   
   always@(posedge lc3if.clk) begin
     if(lc3if.rst)
       IR <= 0;
     if(ldIR)
       IR <= bus;
   end

endmodule
