package Driver_pkg;
	import Opcode_pkg::*;
   	import Transaction_pkg::*;
	import Driver_cbs_pkg::*;
   
class Driver;
   	mailbox #(Transaction) gen2drv;
   	Driver_cbs cbs[$];
	logic [15:0] inst;

   	function new(mailbox #(Transaction) gen2drv);
   	  this.gen2drv = gen2drv;
   	endfunction // new

   	task run(int num_packets = 100);
   	   Transaction t;
   	   repeat(num_packets) begin
   	  	gen2drv.peek(t);
   	  	foreach(cbs[i]) begin
   	  	   cbs[i].pre_tx(t);
   	  	end
   	  	transmit(t);
   	  	foreach(cbs[i]) begin
   	  	   cbs[i].post_tx(t);
   	  	end
   	  	gen2drv.get(t);
   	   end
   	endtask // run

	task transmit_inst(input Transaction t);
		// put instruction on the memory port 
		// single cycle transactions go here
		//case(t.opcode) 
		//	
		//endcase
	endtask

   	task transmit(input Transaction t);
		case(t.opcode)
			ADD, AND : begin
					inst[15:12] = t.opcode;
					inst[11:9] = t.dr;
					inst[8:6] = t.sr1;
					if (t.imm5_flag== 0) begin
						inst[5:3] = 3'b000; 
						inst[2:0] = t.sr2;
					end
					else begin
						inst[5] = 1'b1; 
						inst[4:0] = t.imm5;
					end
				end
			NOT : begin
				inst[15:12] = t.opcode;
				inst[11:9] = t.dr;
				inst[8:6] = t.sr;
				inst[5:0] = 6'b111111; 
				end
			BR	: begin
				inst[15:12] = t.opcode;
				inst[11:9] = 3'b000; //TODO : this should be N,Z,P
				inst[8:0] = t.PCoffset9;
				end
			JMP	: begin
				inst[15:12] = t.opcode;
				inst[11:9] = 3'b000; 
				inst[8:6] = t.BaseR;
				inst[5:0] = 6'b000000;
				end
			JSR : begin
					inst[15:12] = t.opcode;
					if (t.jsr_flag) begin
						inst[11] = 1'b1; 
						inst[10:0] = t.PCoffset11;
					end
					else begin
						inst[11:9] = 3'b000; 
						inst[8:6] = t.BaseR;
						inst[5:0] = 6'b000000; 
					end
				end
			LD, LDI, LDR, LEA	: begin
					inst[15:12] = t.opcode;
					inst[11:9] = t.dr;
					if (t.opcode == LDR) begin
						inst[8:6] = t.BaseR;
						inst[5:0] = t.offset6;
					end
					else begin
						inst[8:0] = t.PCoffset9;
					end
				end
			ST, STI, STR: begin
				inst[15:12] = t.opcode;
				inst[11:9] = t.sr;
					if (t.opcode == STR) begin
						inst[8:6] = t.BaseR;
						inst[5:0] = t.offset6;
					end
					else begin
					inst[8:0] = t.PCoffset9;
					end
				end
			TRAP: begin
				inst[15:12] = t.opcode;
				inst[11:8] = 4'b0000;
				inst[7:0] = t.trapvect8;
				end
			RTI	: begin
				inst[15:12] = t.opcode;
				inst[11:0] = 12'b000000000000;
				end
		endcase
   	endtask

endclass // Driver
endpackage // Driver_pkg
   
