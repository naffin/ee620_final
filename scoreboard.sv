package Scoreboard_pkg;
   import Transaction_pkg::*;
   import Opcode_pkg::*;
class Scoreboard;
   bit [15:0] reg_file [0:7];
   bit [15:0] pc;
   bit [15:0] ir;
   bit [15:0] mar, mdr;
   bit 	      n, z, p;
   bit [15:0] addr_access_q [$];	
   bit [15:0] data_in_q [$];
   Transaction t;
   mailbox #(Transaction) scb2check;

   function new(mailbox #(Transaction) scb2check);
      this.scb2check = scb2check;
   endfunction

   task process_transaction(ref Transaction t);
      if(t.reset)
	reset_golden();
      else 
	 update_golden();
      set_transaction();
      scb2check.put(t);
      end
   endtask // run

   function void update_golden();
      fetch();
      update_regs_and_flags();
      update_mem();
   endfunction // update_state
   
   function void reset_golden();
      for (int i=0; i<8; i=i+1) reg_file[i] = '0;
      pc = 0;
      ir = 0;
      mar = 0;
      mdr = 0;
      n = 0;
      z = 0;
      p = 0;
   endfunction

   function bit[15:0] get_alu_src2();
      if(t.imm5_flag)
		return signed'(t.imm5);
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
      pc = (t.jsr_flag)?signed'(t.PCoffset11):reg_file[t.BaseR];
   endfunction // exec_jsr

   function void fetch();
      addr_access_q.push_back(pc);
      mar = pc;
      pc++;
      ir = t.get_instruction();
      mdr = ir;
   endfunction // update_state_all_ops

   function void update_regs_and_flags();
      case(t.opcode)
	ADD: 
	  set_dr(t.sr1 + get_alu_src2());
	AND:
	  set_dr(t.sr1 & get_alu_src2());
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

   function void update_mem();
      update_mem_access();
      update_mem_data();
   endfunction

   function void update_mem_access();
      case(t.opcode)
	LD,ST: begin
	   addr_access_q.push_back(pc + signed'(t.PCoffset9));
	   mar = pc + signed'(t.PCoffset9);
	end
	LDR,STR: begin
	   addr_access_q.push_back(reg_file[t.BaseR] + signed'(t.offset6));
	   mar = reg_file[t.BaseR] + signed'(t.offset6);
	end
	LDI,STI: begin
	   addr_access_q.push_back(pc + signed'(t.PCoffset9));
	   addr_access_q.push_back(t.data1);
	   mar = t.data1;
	end
      endcase // case (t.opcode)
   endfunction // update_queues
   
   function void update_mem_data();
      case(t.opcode)
	ST,STI,STR: begin
	   data_in_q.push_back(reg_file[t.sr]);
	   mdr = reg_file[t.sr];
	end
	LD,LDR:
	  mdr = t.data1;
	LDI:
	  mdr = t.data2;
	default:
	  mdr = t.get_instruction();
      endcase
   endfunction // update_access_q
   
   function set_transaction();
      t.reg_file = reg_file;
      t.pc = pc;
      t.ir = ir;
      t.mar = mar;
      t.mdr = mdr;
      t.n = t.n;
      t.z = t.z;
      t.p = t.p;
      t.addr_access_q = addr_access_q;
      t.data_in_q = data_in_q;
   endfunction
endclass // Scoreboard
endpackage
