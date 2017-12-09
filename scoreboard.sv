package Scoreboard_pkg;
   import Transaction_pkg::*;
   import Opcode_pkg;
class Scoreboard;
   bit [15:0] reg_file [0:7];
   bit [15:0] pc;
   bit [15:0] ir;
   bit [15:0] mar, mdr;
   bit 	      n, z, p;
   bit [15:0] addr_access_q [$];	
   bit [15:0] data_in_q [$];
   Transaction t;


   function bit[15:0] get_alu_src2();
      if(t.imm5_flag)
	return signed(imm5);
      else
	return reg_file[t.sr1];
   endfunction // get_alu_src2

   function void set_dr(bit [15:0] value);
      set_nzp(value);
      reg_file[t.dr] = value;
   endfunction // set_dr


   function void set_nzp(bit [15:0] value);
      n = (value < 0)?1:0;
      z = (value == 0)?1:0;
      p = (value > 0)?1:0;
   endfunction // set_nzp

   function void exec_jsr();
      reg_file[7] = pc;
      pc = (jsr_flag)?signed(PCoffset11):reg_file[t.BaseR];
   endfunction // exec_jsr

   function void update_golden();
      fetch();
      exec();
      mem();
   endfunction // update_state
   
   function void fetch();
      addr_access_q.push_back(pc);
      pc++;
      IR = t.get_instruction();
   endfunction // update_state_all_ops

   function void exec();
      case(t.opcode)
	ADD:
	  set_dr(t.sr1 + get_alu_src2(t));
	AND:
	  set_dr(t.sr1 & get_alu_src2(t));
	NOT:
	  set_dr(~t.sr1);
	BR:
	  if(t.n&n | t.z&z | t.p&p)
	    pc = pc + t.PCoffset9;
	JMP:
	  pc = reg_file[t.BaseR];
	JSR:
	  exec_jsr();
	LD, LDR:
	  set_dr(t.data1);
	LDI:
	  set_dr(t.data2);
	LEA:
	  set_dr(pc + PCoffset9);
      endcase
   endfunction // update_state_per_op

   function void mem();
      
      case(t.opcode)
	LD,ST:
	  addr_access_q.push_back(pc + signed(t.PCoffset9));
	LDR,STR:
	  addr_access_q.push_back(reg_file[t.BaseR] + signed(t.PCoffset9));
	LDI,STI: begin
	  addr_access_q.push_back(pc + signed(t.PCoffset9));
	  addr_access_q.push_back(t.data1);
	end
      endcase
      if(t.opcode inside {ST,STI,STR})
	t.data_in_q.push_back(reg_file[t.sr]);
   endfunction // update_access_q

   function void update_data_in_q();
   endfunction
endclass // Scoreboard
endpackage
