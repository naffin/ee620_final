package Coverage_pkg;
   import Coverage_base_pkg::*;
   import Transaction_pkg::*;
   
class Coverage extends Coverage_base;
   Transaction t;
   covergroup cov;
      all_ops: coverpoint t.opcode;

   endgroup // cov

   function new();
      cov = new();
   endfunction
      
      
   function void sample(Transaction t);
      this.t = t;
      cov.sample();
   endfunction
endclass // Coverage
endpackage // Coverage_pkg
   
  
