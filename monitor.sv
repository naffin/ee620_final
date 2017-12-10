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
		   if(!t.reset) begin
			t.addr_access_q = addr_access_q;
			t.data_in_q = data_in_q;
		   end
		   foreach(t.reg_file[i])t.reg_file[i] = $root.top.dut.dp.reg_file[i];
			mon2check.put(t);
			// delete contents in queues
			addr_access_q = {}; 
			data_in_q = {};
		end
	endtask // set_states

   

	task get_data_in();
		while(1) begin
		   @(lc3if.cb) begin
		      if(lc3if.cb.memWE)
			data_in_q.push_back(lc3if.cb.data_in);
		   end
		end
	endtask

	task get_addr_access();
		while(1) begin
		   @(lc3if.cb) begin
		      
		      if(lc3if.cb.ldMAR)begin
			addr_access_q.push_back(lc3if.cb.addr);
			$display("%pns Queue: %p",$time,addr_access_q);
		      end
		   end
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
