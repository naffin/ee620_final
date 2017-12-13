module lc3(lc3_if.DUT lc3if);
	reg enaMARM, enaPC, enaMDR, enaALU,
	  flagWE, ldIR, ldPC, selEAB1,
	  selMARM, regWE;
	reg [1:0] selEAB2, selPC;
	reg [2:0] DR, SR1, SR2;
	reg [1:0] ALUctrl;	
	wire N, Z, P, TB;
	wire [15:0] eabOut, Ra, Rb, Buss;
	wire [15:0] PCOut, ALUOut;
	wire [15:0] IR, MARMUXOut;
	wire [15:0] zext;
	reg selMDR, ldMDR;
	wire rst, clk;
	reg [15:0] MDR, MAR;

	assign zext =  {{8{0}}, IR[7:0]};
	assign MARMUXOut = (selMARM) ? zext : eabOut;

	assign rst = lc3if.rst;
	assign clk = lc3if.clk;
	assign lc3if.addr= MAR;
	assign lc3if.data_in = MDR;

	pc pc_1 (.*);
	eab eab_1(.IR(IR[10:0]), .PC(PCOut), .*);
	regfile8x16 regfile(.*, .writeEN(regWE), .wrAddr(DR), .wrData(Buss), .rdAddrA(SR1),
		 .rdAddrB(SR2), .rdDataA(Ra), .rdDataB(Rb));
	nzp nzp_1 (.*);
	alu alu_1(.IR(IR[4:0]), .IR_5(IR[5]), .*);
	ir ir_1(.*);

	//===========================
	// tri-state buffers
	//===========================
	
	ts_driver tsd_1(.din(MARMUXOut), .dout(Buss), .en(enaMARM));
	ts_driver tsd_2(.din(PCOut), .dout(Buss), .en(enaPC));
	ts_driver tsd_3(.din(ALUOut), .dout(Buss), .en(enaALU));
	ts_driver tsd_4(.din(MDR), .dout(Buss), .en(enaMDR));

	typedef enum logic [3:0] { 
				AND=4'b0101, 
				ADD=4'b0001, 
				NOT=4'b1001, 
				JSR=4'b0100,
				BR=4'b0000, 
				LD=4'b0010,
				LDI=4'b1010,
				LDR=4'b0110,
				LEA=4'b1110,
				ST=4'b0011,
				STI=4'b1011,
				STR=4'b0111, 
				JMP=4'b1100, 
				TRAP=4'b1111,
				RTI=4'b1000,
				RESERVED=4'b1101} Opcode;

	typedef enum {FET0, FET1, FET2, DECODE,
				AND0, ADD0, NOT0, JSR0, JSR1, JSRR1,
				BR0, LD0_ST0, LD1, LD2, LDI0_STI0, LDI1_STI1, LDI2_STI2, 
				LDR0_STR0, LEA0, ST1, ST2, JMP0, 
				TRAP0, TRAP1, TRAP2, RTI0} State;

	State state, next_state; 

	wire Opcode opCode;
	assign opCode = IR[15:12];
	assign TB = (N & IR[11]) |  (Z & IR[10]) | (P & IR[9]);

	// State Machine
	always @ (state or opCode) begin
	 next_state = FET0;
	 case(state) 
	   	FET0:		next_state = FET1; 
	   	FET1:		next_state = FET2; 
	   	FET2:		next_state = DECODE;
	   	DECODE:		case(opCode)
						BR     :	next_state = BR0;  
						ADD    :	next_state = ADD0; 
						LD 	   :	next_state = LD0_ST0; 
						ST 	   :	next_state = LD0_ST0;  
						JSR	   :	next_state = JSR0; 
						AND    :	next_state = AND0; 
						LDR	   :	next_state = LDR0_STR0; 
						STR	   :	next_state = LDR0_STR0; 
						RTI	   :	next_state = FET0; // treat as a NOP 
						NOT    :	next_state = NOT0; 
						LDI	   :	next_state = LDI0_STI0; 
						STI	   :	next_state = LDI0_STI0;
						JMP    :	next_state = JMP0; 
						RESERVED:	next_state = FET0; // RESERVED, treat as a NOP; 
						LEA	   :	next_state = LEA0; 
						TRAP   :	next_state = TRAP0; 
						default: 	next_state = FET0;
					endcase 
		ADD0: 		next_state = FET0;
		AND0: 		next_state = FET0;
		NOT0: 		next_state = FET0;
		LD0_ST0:begin
			if(opCode == LD)
			 	next_state = LD1;
			if(opCode == ST)
			 	next_state = ST1;
			end
		LD1: 		next_state = LD2;
		LD2: 		next_state = FET0;
		ST1: 		next_state = ST2;
		ST2: 		next_state = FET0;
		LDI0_STI0:	next_state = LDI1_STI1;
		LDI1_STI1:	next_state = LDI2_STI2;
		LDI2_STI2: begin	
			if(opCode == LDI)
				next_state = LD1;
			if(opCode == STI)
				next_state = ST1;
			end
		LDR0_STR0 : begin	
			if(opCode == LDR)
				next_state = LD1;
			if(opCode == STR)
				next_state = ST1;
			end
		BR0: 		next_state = FET0;
		JMP0: 		next_state = FET0;
		JSR0: begin
			if(IR[11] == 1'b1) next_state = JSR1;
			else next_state = JSRR1;
			end
		JSR1: 		next_state = FET0;
		JSRR1: 		next_state = FET0;
		TRAP0: 		next_state = TRAP1;
		TRAP1: 		next_state = TRAP2;
		TRAP2: 		next_state = FET0;
		LEA0: 		next_state = FET0;
		
	   default : next_state = FET0;
	  endcase
	end


  always @(posedge clk) begin
    if (rst == 1'b1) begin 
		MDR  <= '0; 
		MAR <= '0;
	end
	else if (ldMDR)
	    MDR <= selMDR ? lc3if.data_out : Buss;
	else if (lc3if.ldMAR)
	    MAR <= Buss;
  end
	
	//----------------Sequential Logic--------------------
	always @ (posedge clk) begin 
	  if (rst == 1'b1) begin
	    state <= FET0;
	  end else begin
	    state <= next_state;
	  end
	end

	//--------------------Output Logic--------------------
	always @(*) begin
		lc3if.ldMAR <= 1'b0;
		ldPC  <= '0;
		ldMDR <= '0;
		ldIR <= '0;
		regWE <= '0;
		flagWE <= '0;
		lc3if.memWE <= 1'b0;
		//=== select signals default ====
		selMARM<= '0;
		selMDR<= '0;
		selEAB2 <= '0;
		selEAB1 <= '0;
		selMARM <= '0;
		selPC<= '0;
		//=== enable signals default ====
		enaPC <= '0;
		enaMDR <= '0;
		enaALU <= '0;
		enaMARM <= '0;	
		  unique case(state)
	   		FET0:  	begin
					enaPC <= 1'b1;
					lc3if.ldMAR <= 1'b1;
				end
	   		FET1:  	begin
					selPC <= 2'b00;
					ldPC  <= 1'b1;
					selMDR<= 1'b1;
					ldMDR <= 1'b1;
				end	
	   		FET2:  	begin
					enaMDR<= 1'b1;
					ldIR  <= 1'b1;
				end
	   		DECODE:	begin
				end
	   		ADD0:begin
					SR1 <= IR[8:6];	
					SR2 <= IR[2:0];	
					DR <= IR[11:9];
					ALUctrl <= 2'b00;
					enaALU	<= 1'b1;	
					regWE <= 1'b1;	
					flagWE <= 1'b1;	
				end
	   		NOT0:begin
					SR1 <= IR[8:6];	
					DR <= IR[11:9];
					ALUctrl <= 2'b10;
					enaALU	<= 1'b1;
					regWE <= 1'b1;	
					flagWE <= 1'b1;	
				end
			AND0:begin
					SR1 <= IR[8:6];	
					SR2 <= IR[2:0];	
					DR <= IR[11:9];
					ALUctrl <= 2'b01;
					enaALU	<= 1'b1;
					regWE <= 1'b1;	
					flagWE <= 1'b1;	
				end
			LD0_ST0:begin // MEMORY to REGFILE
					// send address to memory
					selEAB2 <= 2'b10; 	// load in sign extended PCoffset9
					selEAB1 <= 1'b0;  	// load in current PC
					selMARM <= 1'b0; 	// select output of PC+PCoffset9 to drive Buss
					enaMARM <= 1'b1;	
					lc3if.ldMAR <= 1'b1;
				end
			LD1:begin
					// write data from memory to MDR reg
					selMDR <= 1'b1;		// sel data from memory
					ldMDR  <= 1'b1;		// load data from memory into MDR
				end
			LD2:begin
					// write data from MDR to regfile
					regWE <= 1'b1;	
					enaMDR <= 1'b1;		// drive MDR data onto bus
					DR <= IR[11:9];
					flagWE <= 1'b1;	
				end
			LDI0_STI0:begin // MAR <- PC+off9
					lc3if.ldMAR <= 1'b1;
					enaMARM <= 1'b1;
					selMARM <= 1'b0;
					selEAB2 <= 2'b10;
					selEAB1 <= 1'b0;
				end
			LDI1_STI1:begin // MDR <- Mem[MAR] 
					selMDR <= 1'b1;
					ldMDR <= 1'b1;
				end
			LDI2_STI2:begin // MAR <- MDR 
					lc3if.ldMAR <= 1'b1;
					enaMDR<= 1'b1;
				end
			LDR0_STR0:begin // MAR <- MDR 
					selEAB1 <= 1'b1;	
					selEAB2 <= 2'b01;	
					enaMARM <= 1'b1;
					selMARM <= 1'b0;
					lc3if.ldMAR<= 1'b1;
					SR1 <= IR[8:6];
				end
			ST1:begin
					// write data from regfile to memory
					enaALU <= 1'b1;		
					ALUctrl <= 2'b11;
					selMDR <= 1'b0;		// sel data from Buss
					ldMDR  <= 1'b1;	
					SR1 <= IR[11:9];
				end
			ST2:begin
					lc3if.memWE <= 1'b1;
				end
			BR0:begin
					selPC <= 2'b01;
					selEAB2 <= 2'b10;		
					selEAB1 <= 1'b0;	
					ldPC <= TB;	
				end
			JMP0:begin 
					SR1 <= IR[8:6];
					selPC <= 2'b01;
					selEAB2 <= 2'b00;		
					selEAB1 <= 1'b1;	
					ldPC <= 1'b1;	
				end
			JSR0:begin 
					DR <= 3'b111;
					regWE <= 1'b1;	
					enaPC <= 1'b1;
				end
			JSR1:begin 
					selPC <= 2'b01;
					selEAB1 <= 1'b0;	
					selEAB2 <= 2'b11;		
					ldPC <= 1'b1;	
				end
			JSRR1:begin 
					selPC <= 2'b01;
					selEAB1 <= 1'b1;	
					selEAB2 <= 2'b00;		
					ldPC <= 1'b1;	
					SR1 <= IR[8:6];
				end
			TRAP0:begin 
					enaMARM <= 1'b1;
					selMARM <= 1'b1;
					lc3if.ldMAR <= 1'b1;
				end
			TRAP1:begin 
					selMDR <= 1'b1;		
					ldMDR  <= 1'b1;	
					enaPC <= 1'b1;
					regWE <= 1'b1;
					DR <= 3'b111;
				end
			TRAP2:begin 
					enaMDR <= 1'b1;
					selPC <= 2'b10;
					ldPC <= 1'b1;
				end
			LEA0:begin // DR <– PC+off9
					DR <= IR[11:9];
					regWE <= 1'b1;	
					flagWE <= 1'b1;	
					selEAB1 <= 1'b0;
					selEAB2 <= 2'b10;
					selMARM <= 1'b0;
					enaMARM <= 1'b1;
				end
		   default : begin
					end
		  endcase
	end // End Of Block OUTPUT_LOGIC

endmodule
