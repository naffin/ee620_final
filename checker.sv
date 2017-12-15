`define CHECKER_COMPARE(member) \
  do begin\
     if(t_scb.member != t_mon.member) begin \
	string str = `"member`"; \
	$display("%0tns ERROR with %p",$time,str); \
	$display("Expected:"); \
	$display("%p",t_scb.member); \
	$display("Actual:"); \
	$display("%p",t_mon.member); \
        error_flag = 1; \
     end \
  end while(0)
	
       

package Checker_pkg;
	import Transaction_pkg::*;
   import Coverage_base_pkg::*;
class Checker;
	Transaction t_scb, t_mon;
	// mailbox from scoreboard to checker
	mailbox #(Transaction) scb2check;
	mailbox #(Transaction) mon2check;
   bit 		error_flag = 0;
   
   
     Coverage_base cov;
	function new(mailbox #(Transaction) scb2check, mon2check);
		this.scb2check = scb2check;
		this.mon2check = mon2check;
	endfunction

	function bit compare();
	   `CHECKER_COMPARE(pc);
	   `CHECKER_COMPARE(ir);
	   `CHECKER_COMPARE(mar);
	   `CHECKER_COMPARE(mdr);
	   `CHECKER_COMPARE(n);
	   `CHECKER_COMPARE(z);
	   `CHECKER_COMPARE(p);
	   `CHECKER_COMPARE(addr_access_q);
	   `CHECKER_COMPARE(reg_file);
	   if(error_flag) begin
	      $display("Golden Transaction:");
	      t_scb.print();
	      $display("DUT Transaction:");
	      t_mon.print();
	      return 0;
	   end
	   return 1;
	endfunction

	task run();
	   forever begin
		scb2check.get(t_scb);
		mon2check.get(t_mon);
		if(compare())
		   cov.sample(t_mon);
		else begin
		   Transaction::error_found = 1;
		   break;
		end
	      if($get_coverage() == 100)
	      	break;
	   end
	endtask

endclass // checker
endpackage // Checker_pkg
