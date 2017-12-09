package Driver_pkg;
   import Opcode_pkg::*;
   import Transaction_pkg::*;
   import Driver_cbs_pkg::*;
   
class Driver;
   mailbox #(Transaction) gen2drv;
   mailbox #(Transaction) drv2mon;
   Driver_cbs cbs[$];
   logic [15:0] inst;
   virtual lc3_if.TEST lc3if;

   function new(mailbox #(Transaction) gen2drv,mailbox #(Transaction) drv2mon, 
				input virtual lc3_if.TEST lc3if);
      this.gen2drv = gen2drv;
      this.drv2mon = drv2mon;
      this.lc3if = lc3if;
   endfunction // new

   task run();
      Transaction t;
      gen2drv.peek(t);
      while(1) begin
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

   task transmit_inst();
	  int num_clks = 0;

	  case(t.opcode) :
	     RTI, RESERVED: num_clks = 3;
	     ADD, AND, NOT, JMP, LEA : num_clks = 4;
	     BR, JSR: num_clks = 5;
	     LD, ST, LDR, STR, TRAP : num_clks = 6;
		 LDI, STI : num_clks = 8; 
	  endcase

	  for(int i = 0; i < num_clks; i++) begin 
	     if (t.reset == 1 && i == t.rst_counter) begin
	     	lc3if.reset = 1; 
	     	break;
	     end
	     if (i == 4) lc3if.cb.data_out = t.data1; 	
	     if (i == 6) lc3if.cb.data_out = t.data2; 	
      	@(lc3if.cb); 
	  end
      @(lc3if.cb); // return to fetch_0 state 
   endtask

   task transmit(input Transaction t);
      inst = t.get_instruction();
      transmit_inst();
   endtask

endclass // Driver
endpackage // Driver_pkg
