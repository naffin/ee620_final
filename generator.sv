`define SV_RAND_CHECK(r) \
  do begin \
    if (!(r)) begin \
      $display("%s:%0d: Randomization failed \"%s\"", \
               `__FILE__, `__LINE__, `"r`"); \
      $finish; \
    end \
  end while (0)
    
package Generator_pkg;
	import Transaction_pkg::*;
class Generator;
   mailbox #(Transaction) gen2drv;
   Transaction blueprint;

   function new(mailbox #(Transaction) gen2drv);
      this.gen2drv = gen2drv;
      blueprint = new();
   endfunction 

   
   task run(int num_trans);
      blueprint.reset = 1;
      gen2drv.put(blueprint.copy());
      if(num_trans == 0) 
	 forever begin
	    `SV_RAND_CHECK(blueprint.randomize());
	    gen2drv.put(blueprint.copy());
	 end
      else
	 repeat(num_trans - 2) begin
	    `SV_RAND_CHECK(blueprint.randomize());
	    gen2drv.put(blueprint.copy());
	 end
   endtask
endclass // Generator
   
endpackage
