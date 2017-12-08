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

   function void set_reg(bit [15:0] value);
      set_nzp(value);
      reg_file[t.dr] = value;
   endfunction // set_reg


   function void set_nzp(bit [15:0] value);
      n = (value < 0)?1:0;
      z = (value == 0)?1:0;
      p = (value > 0)?1:0;
   endfunction // set_nzp
   
   function exec_transaction();
      adddr_access.push_back(pc);
      pc++;
      case(t.opcode)
	ADD:
	  set_reg(t.sr1 + get_alu_src2(t));
	AND:
	  set_reg(t.sr1 & get_alu_src2(t));
	NOT:
	  set_reg(~t.sr1);
	BR:
	  set
	   
	end
      endcase
   endfunction
endclass // Scoreboard
endpackage
