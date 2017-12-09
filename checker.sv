package Checker_pkg;
	import Transaction_pkg::*;
   import Coverage_base_pkg::*;
class Checker;
	Transaction t_scb, t_mon;
	// mailbox from scoreboard to checker
	mailbox #(Transaction) scb2check;
	mailbox #(Transaction) mon2check;;
     Coverage_base cov;
	function new(mailbox #(Transaction) scb2check, mon2check);
		this.scb2check = scb2check;
		this.mon2check = mon2check;
	endfunction

	function void print_addr_queue(Transaction t);
		foreach(t.addr_access_q[i])
			$display(t.addr_access_q[i]);
	endfunction

	function void print_data_in_queue(Transaction t);
		foreach(t.data_in_q[i])
			$display(t.data_in_q[i]);
	endfunction

	function void compare();
		if(t_scb.addr_access_q.size() != t_mon.addr_access_q.size()) begin
			$display("0%t ERROR: address access queue sizes don't match",$time);
			$display("Expected:");
			print_addr_queue(t_scb);
			$display("Actual:");
			print_addr_queue(t_mon);
		end
		else begin
			foreach(t_scb.addr_access_q[i]) begin
				if(t_scb.addr_access_q[i] != t_mon.addr_access_q[i]); begin
					$display("0%t ERROR: address access incorrect",$time);
					$display("Expected:");
					print_addr_queue(t_scb);
					$display("Actual:");
					print_addr_queue(t_mon);
				end
			end
		end
	endfunction

	task run();
	   forever begin
		scb2check.get(t_scb);
		mon2check.get(t_mon);
		compare();
	      cov.sample(t_mon);
	   end
	endtask

endclass // checker
endpackage // Checker_pkg
