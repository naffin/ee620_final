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

	virtual task set_states();
		while(1) begin
			drv2mon.get(t);
		   if(!t.reset) begin
			t.addr_access_q = addr_access_q;
			t.data_in_q = data_in_q;
		   end
		   foreach(t.reg_file[i])t.reg_file[i] = $root.top.dut.regfile.regfile[i];
		   t.pc = $root.top.dut.PCOut;
		   t.ir = $root.top.dut.IR;
		   t.mar = $root.top.lc3if.addr;
		   t.mdr = $root.top.lc3if.data_in;
		   t.n = $root.top.dut.N;
		   t.z = $root.top.dut.Z;
		   t.p = $root.top.dut.P;
			mon2check.put(t);
			// delete contents in queues
			addr_access_q = {}; 
			data_in_q = {};
		end
	endtask // set_states

   

	task get_data_in();
		while(1) begin
		   @lc3if.cb;
		   if(lc3if.cb.memWE)
		     data_in_q.push_back(lc3if.cb.data_in);
		end
	endtask

	task get_addr_access();
		while(1) begin
		   @ lc3if.cb;
		   if(lc3if.cb.ldMAR)begin
		      @lc3if.cb;
		      addr_access_q.push_back(lc3if.cb.addr);
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
