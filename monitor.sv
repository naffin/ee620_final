package monitor_pkg;
	import transaction_pkg::*;
class monitor;
	// coverage call backs
	virtual lc3_if.MONITOR lc3if;
	Transaction t;
	mailbox #(Transaction) drv2mon;
	mailbox #(Transaction) mon2check;
	bit [15:0] addr_access_q [$];
	bit [15:0] data_in_q [$];	
	bit [15:0] reg_file [0:7];

	function new(mailbox #(Transaction) drv2mon, virtual lc3_if.MONITOR lc3if);
		this.drv2mon = drv2mon;	
		this.lc3if = lc3if;
		t = new;
	endfunction

	task set_states();
		while(1) begin
			@(drv2mon.peek(t));
			t.addr_access_q = addr_access_q;
			t.data_in_q = data_in_q;
			t.reg_file = $root.top.DUT.reg_file;
			mon2check.put(t);
			// delete contents in queues
			addr_access_q = {}; 
			data_in_q = {};
		end
	endtask

	task set_queues();
		while(1) begin
			@(lc3if.cb.memWE);
			addr_access_q.push_back(lc3if.cb.addr);
			data_in_q.push_back(lc3if.cb.data_in);
		end	
	endtask

	task run();
		fork
			set_states();
			set_queues();
		join	
	endtask
endclass // monitor
endpackage
