package Coverage_pkg;
   import Coverage_base_pkg::*;
   import Transaction_pkg::*;
   import Opcode_pkg::*;
class Coverage extends Coverage_base;
   Transaction t;
   int unsigned num_reg_value_bins = 1024;
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

   covergroup reset_all_cycles();
      ops_3_cycles: coverpoint t.opcode{
	 bins ops_3_cycles[] = {RTI,RESERVED};
	 option.weight=0;
      }
      ops_4_cycles: coverpoint t.opcode{
	 bins ops_4_cycles[] = {ADD,AND,NOT,JMP,LEA,BR};
	 option.weight=0;
      }
      ops_5_cycles: coverpoint t.opcode{
	 bins ops_5_cycles[] = {JSR};
	 option.weight=0;
      }
      ops_6_cycles: coverpoint t.opcode{
	 bins ops_6_cycles[] = {LD,ST,LDR,STR,TRAP};
	 option.weight=0;
      }
      ops_8_cycles: coverpoint t.opcode{
	 bins ops_8_cycles[] = {LDI,STI};
	 option.weight=0;
      }

      rst_counter_3: coverpoint t.rst_counter{
	 bins rst_counter_3[] = {[0:3]};
	 option.weight=0;
      }
      rst_counter_4: coverpoint t.rst_counter{
	 bins rst_counter_4[] = {[0:4]};
	 option.weight=0;
      }
      rst_counter_5: coverpoint t.rst_counter{
	 bins rst_counter_5[] = {[0:5]};
	 option.weight=0;
      }
      rst_counter_6: coverpoint t.rst_counter{
	 bins rst_counter_6[] = {[0:6]};
	 option.weight=0;
      }
      rst_counter_8: coverpoint t.rst_counter{
	 bins rst_counter_8[] = {[0:8]};
	 option.weight=0;
      }

      rst_3_cross: cross ops_3_cycles,rst_counter_3;
      rst_4_cross: cross ops_4_cycles,rst_counter_4;
      rst_5_cross: cross ops_5_cycles,rst_counter_5;
      rst_6_cross: cross ops_6_cycles,rst_counter_6;
      rst_8_cross: cross ops_8_cycles,rst_counter_8;
   endgroup // reset_all_cycles

   covergroup consecutive_ops(); //Needs to be non reset transaction back to back
      consecutive_opc: coverpoint t.opcode{
	 bins consecutive_ops[] = ([0:$] => [0:$]);
      }
   endgroup // consecutive_ops

   covergroup values_in_regs();
      pc_values: coverpoint t.pc{option.auto_bin_max=num_reg_value_bins;}
   endgroup // values_in_regs

   bit [2:0] nzp_regs;
   covergroup br_control();
      br_nzp: coverpoint t.br_nzp iff (t.opcode == BR) {option.weight = 0;}
      nzp_regs: coverpoint nzp_regs {
	 bins nzp_regs[] = {3'b0,3'b001,3'b010,3'b100};
	 option.weight = 0;
      }
      control_cross: cross br_nzp,nzp_regs;
   endgroup
   

   function new();
      all_ops = new();
      all_instruction_regs = new();
      reset_all_cycles = new();
      consecutive_ops = new();
      values_in_regs = new();
      br_control = new();
   endfunction
      
      
   function void sample(Transaction t);
      this.t = t;
      nzp_regs = {t.n,t.z,t.p};
      values_in_regs.sample();
      if(!t.reset) begin
	 all_ops.sample();
	 all_instruction_regs.sample();
	 consecutive_ops.sample();
	 br_control.sample();
      end
      if(t.reset) begin
	 reset_all_cycles.sample();
      end
   endfunction
endclass // Coverage
endpackage // Coverage_pkg
   
  
