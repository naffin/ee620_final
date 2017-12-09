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
   

class Config;
   rand bit [31:0] run_for_n_trans;
   constraint num_trans {
      run_for_n_trans == 1000;
   }
endclass : Config

class Environment;
   virtual lc3_if.TEST lc3if;
   mailbox #(Transaction) gen2drv,drv2mon,mon2check,scb2check; 
   Generator gen;
   Driver drv;
   Config cfg;
   Scoreboard scb;

   function new (virtual lc3_if.TEST lc3if)
      this.lc3if = lc3if;
   endfunction

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
      
   endfunction
   
   task run();
      fork
	 gen.run(cfg.run_for_n_trans);
	 drv.run(cfg.run_for_n_trans);
      join
   endtask // run

   function void gen_cfg();
      cfg = new();
      `SV_RAND_CHECK(cfg.randomize());
   endfunction
   
   task wrap_up();
      //$display("Number of transactions sent: %0d", scb.num_compared);
      $display("Wrap_up called");
	endtask
endclass
endpackage

