package Driver_cbs_scb_pkg;
   import Driver_cbs_pkg::*;
   import Transaction_pkg::*;
   import scoreboard_pkg::*;
class Driver_cbs_scb extends Driver_cbs;
   Scoreboard scb;

   function new(Scoreboard scb);
      this.scb = scb;
   endfunction
   
   virtual task post_tx(ref Transaction t);
      Transaction t_copy =t.copy();
      scb.process_transaction(t_copy);
   endtask // post_tx
   
endclass
endpackage
