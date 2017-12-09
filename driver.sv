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
      //case(t.opCode) 
      //	
      //endcase
   endtask

   task transmit(input Transaction t);
      inst = t.get_instruction();
   endtask

endclass // Driver
endpackage // Driver_pkg
   
