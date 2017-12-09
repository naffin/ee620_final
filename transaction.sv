package Transaction_pkg;
	import Opcode_pkg::*;
class Transaction;
	// stimulus
	rand OpCode opcode;
	rand bit [2:0] dr;
	rand bit [2:0] sr;
	rand bit [2:0] sr1;
	rand bit [2:0] sr2;
	rand bit [4:0] imm5;
	rand bit [8:0] PCoffset9;
	rand bit [8:0] PCoffset6;
	rand bit [10:0] PCoffset11;
	rand bit [5:0] offset6;
	rand bit [2:0] BaseR;
	rand bit [7:0] trapvect8;
	rand bit imm5_flag;
	rand bit jsr_flag;
	rand bit [15:0] data1, data2;
	rand bit [2:0] rst_counter;
   rand bit reset;
   
	
	// state 
	bit [15:0] reg_file [0:7];
	bit [15:0] pc;
	bit [15:0] ir;
	bit [15:0] mar, mdr;
	bit n, z, p;

	// queues
 	bit [15:0] addr_access_q [$];	
	bit [15:0] data_in_q [$];	

	constraint rst_counter_value {
		// set rst_counter constraints based on the opCode	
	};

	function Transaction copy();
		copy = new this;	
	endfunction // copy

	function bit [15:0] get_instruction();
	   bit [15:0] inst;
	   inst[15:12] = opcode;
	   case(opcode)
	     ADD, AND : begin
		inst[11:6] = {dr,sr1};
		inst[5:0] = (imm5_flag)?{1'b1,imm5}:{3'b0,sr2};
	     end
	     NOT : 
	       inst[11:0] = {dr,sr,6'b111111};
	     BR	: 
	       inst[11:0] = {n,z,p,PCoffset9}; //TODO : this should be N,Z,P
	     JMP : 
	       inst[11:0] = {3'b000,BaseR,6'b000000};
	     JSR : 
	       inst[11:0] = (jsr_flag)? {1'b1,PCoffset11}:
			    {3'b000,BaseR,6'b000000};
	     LD,LDI,LEA: 
	       inst[11:0] = {dr,PCoffset9};
	     LDR:
	       inst[11:0] = {dr,BaseR,PCoffset6};
	     ST,STI: 
	       inst[11:0] = {sr,PCoffset9};
	     STR:
	       inst[11:0] = {sr,BaseR,PCoffset6};
	     TRAP: 
	       inst[11:0] = {4'b0000,trapvect8};
	     RTI: 
	       inst[11:0] = 12'b000000000000;
	   endcase
	endfunction
endclass
endpackage


