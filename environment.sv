`define SV_RAND_CHECK(r) \
  do begin \
    if (!(r)) begin \
      $display("%s:%0d: Randomization failed \"%s\"", \
               `__FILE__, `__LINE__, `"r`"); \
      $finish; \
    end \
  end while (0)
    
package Environment_pkg;
   import Scoreboard_pkg::*;
   import Transaction_pkg::*;
   import Generator_pkg::*;
   import Driver_pkg::*;
   import Monitor_pkg::*;
   import Checker_pkg::*;

class Config;
   int unsigned run_for_n_trans = 10000;
   function new();
      if($value$plusargs("NUM_TRANS=%d", run_for_n_trans))
	if(run_for_n_trans == 0)
	  $display("Config set to run until coverage complete.");
	else
	  $display("Config set to run for %d transactions.",run_for_n_trans);
   endfunction
endclass : Config

class Environment;
   virtual lc3_if lc3if = $root.top.lc3if;
   mailbox #(Transaction) gen2drv,drv2mon,mon2check,scb2check; 
   Generator gen;
   Driver drv;
   Config cfg;
   Scoreboard scb;
   Checker check;
   Monitor mon;
      
   function void build();
      // initialize mailbox
      gen2drv = new(1);
      drv2mon = new(1);
      mon2check = new(1);
      scb2check = new(1);
      
      // initialize transactors
      gen = new(gen2drv);
      drv = new(gen2drv,drv2mon,lc3if);
      scb = new(scb2check);
      mon = new(drv2mon,mon2check,lc3if);
      check = new(scb2check,mon2check);
   endfunction
   
   task run();
      fork
	 gen.run(cfg.run_for_n_trans);
	 drv.run();
	 mon.run();
	 check.run();
      join_any
   endtask // run

   function void gen_cfg();
      cfg = new();
   endfunction
   
   task wrap_up();
      $display("Number of transactions sent: %0d", Transaction::trans_count);
   endtask
endclass
endpackage

