package Coverage_pkg;
   import Coverage_base_pkg::*;
   import Transaction_pkg::*;
   import Opcode_pkg::*;
class Coverage extends Coverage_base;
   Transaction t;
   int unsigned num_conseq_trans;
   const int unsigned max_num_bins = 1024;
   int unsigned target_conseq_trans = 100000;
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

   bit [4:0] rst_opcode;
   
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

   covergroup consecutive_ops();
      consecutive_opc: coverpoint rst_opcode{
	 bins consecutive_ops[] = ([0:5'b01111] => [0:5'b01111]);
      }
   endgroup // consecutive_ops

   covergroup offsets_and_imm5();
      option.auto_bin_max = max_num_bins;
      imm5_ops: coverpoint t.opcode{
	 bins imm5_ops[] = {ADD,AND} iff (t.imm5_flag);
	 option.weight = 0;
      }
      offset9_ops: coverpoint t.opcode{
	 bins offset9_ops[] = {BR,LD,LDI,LEA,ST,STI};
	 option.weight = 0;
      }
      offset11_ops: coverpoint t.opcode{
	 bins offset11_ops = {JSR} iff (t.jsr_flag);
	 option.weight = 0;
      }
      offset6_ops: coverpoint t.opcode{
	 bins offset6_ops[] = {LDR,STR};
	 option.weight = 0;
      }
      trapvect8_ops: coverpoint t.opcode{
	 bins trapvect8_ops = {TRAP};
	 option.weight = 0;
      }
      imm5: coverpoint t.imm5 {option.weight = 0;}
      offset9: coverpoint t.PCoffset9{option.weight = 0;}
      offset11: coverpoint t.PCoffset11{option.weight = 0;}
      offset6: coverpoint t.offset6{option.weight = 0;}
      trapvect8: coverpoint t.trapvect8{option.weight = 0;}

      imm5_cross: cross imm5_ops,imm5;
      offset9_cross: cross offset9_ops,offset9;
      offset11_cross: cross offset11_ops,offset11;
      offset6_cross: cross offset6_ops,offset6;
      trapvect8_cross: cross trapvect8_ops,trapvect8;
   endgroup

   covergroup values_in_regs();
      option.auto_bin_max=max_num_bins;
      pc_values: coverpoint t.pc;
      mar_values: coverpoint t.mar;
      mdrMDR_values: coverpoint t.mdr;
      reg_file_0: coverpoint t.reg_file[0];
      reg_file_1: coverpoint t.reg_file[1];
      reg_file_2: coverpoint t.reg_file[2];
      reg_file_3: coverpoint t.reg_file[3];
      reg_file_4: coverpoint t.reg_file[4];
      reg_file_5: coverpoint t.reg_file[5];
      reg_file_6: coverpoint t.reg_file[6];
      reg_file_7: coverpoint t.reg_file[7];
   endgroup // values_in_regs

   bit [2:0] nzp_regs;
   covergroup br_control();
      br_nzp: coverpoint t.br_nzp iff (t.opcode == BR) {option.weight = 0;}
      nzp_regs: coverpoint nzp_regs {
	 bins nzp_regs[] = {3'b0,3'b001,3'b010,3'b100};
	 option.weight = 0;
      }
      control_cross: cross br_nzp,nzp_regs;
   endgroup // br_control

   covergroup num_conseq_trans_cov();
      num_conseq_trans_cov: coverpoint num_conseq_trans{
	 bins num_conseq_trans_cov = {target_conseq_trans};
      }
   endgroup

   function new();
      num_conseq_trans = 0;
      all_ops = new();
      all_instruction_regs = new();
      reset_all_cycles = new();
      consecutive_ops = new();
      values_in_regs = new();
      br_control = new();
      offsets_and_imm5 = new();
      num_conseq_trans_cov = new();
   endfunction
      
      
   function void sample(Transaction t);
      this.t = t;
      nzp_regs = {t.n,t.z,t.p};
      rst_opcode = {t.reset,t.opcode};
      values_in_regs.sample();
      num_conseq_trans_cov.sample();
      if(!t.reset) begin
	 num_conseq_trans++;
	 all_ops.sample();
	 all_instruction_regs.sample();
	 consecutive_ops.sample();
	 br_control.sample();
	 offsets_and_imm5.sample();
      end
      if(t.reset) begin
	 num_conseq_trans = 0;
	 reset_all_cycles.sample();
      end
   endfunction // sample
endclass // Coverage
endpackage // Coverage_pkg
   
  
