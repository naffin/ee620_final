package Checker_pkg::*;
	import Transaction_pkg::*;
class checker;
	Transaction t_scb, t_mon;
	// mailbox from scoreboard to checker
	mailbox #(Transaction) scb2check;
	mailbox #(Transaction) mon2check;;

	function new(Transaction t_scb, t_mon);
		this.t_scb = t_scb;
		this.t_mon = t_mon;
	endfunction

	function print_addr_queue(Transaction t);
		foreach(t.addr_access_q[i])
			$display(t.addr_access_q[i]);
	endfunction

	function print_data_in_queue(Transaction t);
		foreach(t.data_in_q[i])
			$display(t.data_in_q[i]);
	endfunction

	function compare();
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
		@(scb2check.get(t_scb));
		@(mon2check.get(t_mon));
		compare();
	endtask

endclass // checker
endpackage // Checker_pkg