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

	function new(mailbox #(Transaction) drv2mon, virtual lc3_if.MONITOR lc3if);
		drv2mon.this = drv2mon;	
		this.lc3if = lc3if;
		t = new;
	endfunction


	task set_states();
		while(); begin
			@(drv2mon.peek(t));
			t.addr_access_q = addr_access_q;
			t.data_in_q = data_in_q;
			mon2check.put(t);
		end
	end

	task set_queues();
		while(); begin
			@(lc3if.cb);
			addr_access_q.push_back(lc3if.
			
		end	
	end

	task run();
		fork
			set_states();
			set_queues();
		join	
	endtask
endclass // monitor
endpackage
