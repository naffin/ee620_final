package Monitor_pkg;
	import transaction_pkg::*;
class Monitor;
	// coverage call backs
	virtual lc3_if.MONITOR lc3if;
	Transaction t;
	mailbox #(Transaction) drv2mon;
	mailbox #(Transaction) mon2check;
	bit [15:0] addr_access_q [$];
	bit [15:0] data_in_q [$];	
	bit [15:0] reg_file [0:7];

	function new(mailbox #(Transaction) drv2mon, mon2check, virtual lc3_if.MONITOR lc3if);
		this.drv2mon = drv2mon;	
		this.mon2check = mon2check;	
		this.lc3if = lc3if;
		t = new;
	endfunction

	task set_states();
		while(1) begin
			drv2mon.get(t);
			t.addr_access_q = addr_access_q;
			t.data_in_q = data_in_q;
			t.reg_file = $root.top.DUT.reg_file;
			mon2check.put(t);
			// delete contents in queues
			addr_access_q = {}; 
			data_in_q = {};
		end
	endtask

	task get_data_in();
		while(1) begin
			@(lc3if.cb.memWE);
			data_in_q.push_back(lc3if.cb.data_in);
		end
	endtask

	task get_addr_access();
		while(1) begin
			@(lc3if.cb.ldMAR);
			addr_access_q.push_back(lc3if.cb.addr);
		end
	endtask

	task set_queues();
		fork
			get_addr_access();
			get_data_in();
		join
	endtask

	task run();
		fork
			set_states();
			set_queues();
		join	
	endtask
endclass // monitor
endpackage
