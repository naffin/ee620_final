package Driver_cbs_no_rst_pkg;
   import Driver_cbs_pkg::*;
   import Transaction_pkg::*;
class Driver_cbs_no_rst extends Driver_cbs;
   bit init = 0;
   virtual task pre_tx(ref Transaction t);
      if(!init)
	init = 1;
      else
	t.reset = 0;
   endtask // post_tx
   
endclass
endpackage
