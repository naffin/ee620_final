module controller(lc3_if.DUT lc3if,
		  input 	   N, Z, P,
		  input [15:0] 	   IR,
		  output reg 	   enaALU, regWE, enaMARM, selMAR, selEAB1, enaPC, ldPC, ldIR, ldMAR, ldMDR, selMDR, flagWE, enaMDR,
		  output reg [1:0] aluControl, selPC, selEAB2,
		  output reg [2:0] SR1, SR2, DR);

   // Support for any future states
   reg [5:0] 			   state;

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
   parameter STATE_trap0 = 32;
   wire 			   branchEn;
   assign branchEn = ((IR[11]&&N)||(IR[10]&&Z)||(IR[9]&&P));

   // Next state logic
   always @(posedge lc3if.clk)
     begin
	if (lc3if.rst)
	  state <= STATE_fetch0;
	else
	  case (state)
	    STATE_fetch0:
	      state <= STATE_fetch1;
	    STATE_fetch1:
	      state <= STATE_fetch2;
	    STATE_fetch2:
	      state <= STATE_decode;
	    STATE_decode:
	      case(IR[15:12])
		4'b0000:
		  state <= STATE_br0;
		4'b0001:
		  state <= STATE_alu0;
		4'b0010:
		  state <= STATE_ld0;
		4'b0011:
		  state <= STATE_st0;
		4'b0100:
		  state <= STATE_jsr0;
		4'b0101:
		  state <= STATE_alu0;
		4'b1001:
		  state <= STATE_alu0;
		4'b1100:
		  state <= STATE_jmp0;
		4'b1010:
		  state <= STATE_ldi0;
		4'b0110:
		  state <= STATE_ldr0;
		4'b1110:
		  state <= STATE_lea0;
		4'b1011:
		  state <= STATE_sti0;
		4'b0111:
		  state <= STATE_str0;
		4'b1111:
		  state <= STATE_trap0;
		default:
		  state <= STATE_fetch0;
	      endcase
	    STATE_jsr0:
	      state <= STATE_jsr1;
	    STATE_ld0:
	      state <= STATE_ld1;
	    STATE_ld1:
	      state <= STATE_ld2;
	    STATE_st0:
	      state <= STATE_st1;
	    STATE_st1:
	      state <= STATE_st2;
	    default:
	      //The other states all return here
	      state <= STATE_fetch0;
	  endcase
     end

   // Moore outputs
   always @(state)
     begin
	//Set default outputs
	enaALU  	= 1'b0;
	regWE 		= 1'b0;
	flagWE 		= 1'b0;
	enaMARM 	= 1'b0;
	selMAR 		= 1'b0;
	selEAB1 	= 1'b0;
	enaPC 		= 1'b0;
	ldPC 		  = 1'b0;
	ldIR 		  = 1'b0;
	ldMAR 		= 1'b0;
	ldMDR 		= 1'b0;
	selMDR 		= 1'b0;
	lc3if.memWE 	= 1'b0;
	flagWE 		= 1'b0;
	enaMDR 		= 1'b0;
	aluControl= 2'b00;
	selPC 		= 2'b00;
	selEAB2 	= 2'b00;
	SR1 		  = 3'b000;
	SR2 		  = 3'b000;
	DR 			  = 3'b000;
	case (state)
	  STATE_fetch0: begin
	     enaPC = 1'b1;
	     ldMAR = 1'b1;
	  end
	  STATE_fetch1: begin
	     selMDR = 1'b1;
	     ldMDR  = 1'b1;
	     ldPC   = 1'b1;
	  end
	  STATE_fetch2: begin
	     enaMDR = 1'b1;
	     ldIR   = 1'b1;
	  end
	  STATE_decode: begin
	     //No non-zero signals
	  end
	  STATE_alu0: begin
	     SR1 = IR[8:6];
	     SR2 = IR[2:0]; //1001 has this as a dont care
	     DR  = IR[11:9];
	     enaALU = 1'b1;
	     regWE  = 1'b1;
	     flagWE  = 1'b1;
	  end
	  STATE_br0: begin
	     selPC   = 2'b01;
	     selEAB2 = 2'b10;
	     ldPC    = branchEn;
	  end
	  STATE_jmp0: begin
	     SR1     = IR[8:6];
	     selPC   = 2'b01;
	     selEAB1 = 1'b1;
	     ldPC    = 1'b1;
	  end
	  STATE_jsr0: begin
	     DR    = 3'b111;
	     regWE = 1'b1;
	     flagWE = 1'b1;
	     enaPC = 1'b1;
	  end
	  STATE_jsr1: begin
	     selPC   = 2'b01;
	     selEAB2 = 2'b11;
	     ldPC    = 1'b1;
	  end
	  STATE_ld0: begin
	     selEAB2 = 2'b10;
	     enaMARM = 1'b1;
	     ldMAR   = 1'b1;
	  end
	  STATE_ld1: begin
	     ldMDR  = 1'b1;
	     selMDR = 1'b1;
	  end
	  STATE_ld2: begin
	     DR     = IR[11:9];
	     regWE  = 1'b1;
	     flagWE  = 1'b1;
	     enaMDR = 1'b1;
	  end
	  STATE_ldi0: begin
	     selEAB2 = 2'b10;
	     enaMARM = 1'b1;
	     ldMAR = 1'b1;
	  end
	  STATE_ldi1: begin
	     ldMDR = 1'b1;
	     selMDR = 1'b1;
	  end
	  STATE_ldi2: begin
	     ldMAR = 1'b1;
	     enaMDR = 1'b1;
	  end
	  STATE_ldi3: begin
	     ldMDR = 1'b1;
	     selMDR = 1'b1;
	  end
	  STATE_ldi4: begin
	     DR     = IR[11:9];
	     regWE  = 1'b1;
	     flagWE  = 1'b1;
	     enaMDR = 1'b1;
	  end
	  STATE_ldr0: begin
	     SR1 = IR[8:6];
	     selEAB1 = 1'b1;
	     selEAB2 = 2'b01;
	     enaMARM = 1'b1;
	     ldMAR = 1'b1;
	  end
	  STATE_ldr1: begin
	     ldMDR = 1'b1;
	     selMDR = 1'b1;
	  end
	  STATE_ldr2: begin
	     DR     = IR[11:9];
	     regWE  = 1'b1;
	     flagWE  = 1'b1;
	     enaMDR = 1'b1;
	  end
	  STATE_lea0:begin
	     selEAB2 = 2'b10;
	     enaMARM = 1'b1;
	     DR     = IR[11:9];
	     regWE  = 1'b1;
	     flagWE  = 1'b1;
	     enaMDR = 1'b1;
	  end
	  STATE_sti0:begin
	     selEAB2=2'b10;
	     enaMARM=1'b1;
	     ldMAR=1'b1;
	  end
	  STATE_st0: begin
	     selEAB2 = 2'b10;
	     enaMARM = 1'b1;
	     ldMAR		= 1'b1;
	  end
	  STATE_st1: begin
	     SR1 	 = IR[11:9];
	     enaALU = 1'b1;
	     ldMDR  = 1'b1;
	  end
	  STATE_st2: begin
	     lc3if.memWE = 1'b1;
	  end
	endcase
     end

endmodule
