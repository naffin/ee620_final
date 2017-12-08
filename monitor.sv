package monitor_pkg;
	import transaction_pkg::*;
class monitor;
	// coverage call backs
	//  
	mailbox #(Transaction) drv2mon;

	function new(mailbox #(Transaction) drv2mon);
		drv2mon.this = drv2mon;	
	endfunction
endclass // monitor
endpackage
