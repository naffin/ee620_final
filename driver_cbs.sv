package Driver_cbs_pkg;
   import Transaction_pkg::*;
virtual class Driver_cbs;
   
   virtual task pre_tx(ref Transaction t);
   endtask

   virtual task post_tx(ref Transaction t);
   endtask
endclass
endpackage
