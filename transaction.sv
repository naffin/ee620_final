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
	rand bit [10:0] PCoffset11;
	rand bit [5:0] offset6;
	rand bit [2:0] BaseR;
	rand bit [7:0] trapvect8;
	rand bit imm5_flag;
	rand bit jsr_flag;
	rand bit [15:0] data1, data2;
	rand bit [2:0] rst_counter;
	
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
	endfunction
endclass
endpackage


