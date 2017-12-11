package Coverage_pkg;
   import Coverage_base_pkg::*;
   import Transaction_pkg::*;
   import Opcode_pkg::*;
class Coverage extends Coverage_base;
   Transaction t;
   covergroup all_ops();
      all_ops: coverpoint t.opcode;
   endgroup // all_ops

   covergroup all_instruction_regs();
      dr_ops: coverpoint t.opcode{
      	 bins dr_ops[] = {ADD,AND,NOT,LD,LDI,LDR,LEA};
	 option.weight=0;
      }
      sr_1_2_ops: coverpoint t.opcode{
	 bins sr_1_2_ops[] = {AND,AND};
	 option.weight=0;
      }
      sr_ops: coverpoint t.opcode{
      	 bins sr_ops[] = {NOT,ST,STI,STR};
	 option.weight=0;
      }
      BaseR_ops: coverpoint t.opcode{
	 bins base_r_ops[] = {JMP,LDR,STR};
	 bins base_r_JSRR = {JSR} iff (!t.jsr_flag);
	 option.weight=0;
      }
      
      dr: coverpoint t.dr {option.weight = 0;}
      sr1: coverpoint t.sr1 {option.weight = 0;}
      sr2: coverpoint t.sr2 iff (!t.imm5_flag) {option.weight = 0;}
      sr: coverpoint t.sr {option.weight = 0;}
      BaseR: coverpoint t.BaseR {option.weight = 0;}
      
      dr_cross: cross dr_ops,dr;
      sr1_cross: cross sr1,sr_1_2_ops;
      sr2_cross: cross sr2,sr_1_2_ops;
      sr_cross: cross sr,sr_ops;
      BaseR_cross: cross BaseR,BaseR_ops;
   endgroup // all_instruction_regs
   

   function new();
      all_ops = new();
      all_instruction_regs = new();
   endfunction
      
      
   function void sample(Transaction t);
      this.t = t;
      if(!t.reset) begin
	 all_ops.sample();
	 all_instruction_regs.sample();
      end
   endfunction
endclass // Coverage
endpackage // Coverage_pkg
   
  
