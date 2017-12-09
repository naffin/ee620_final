interface lc3_if (input bit clk);
	bit rst;
	bit [15:0] data_out, data_in;
	logic [15:0] addr;
	logic memWE,ldMAR;
	
	clocking cb @(posedge clk);
		output data_out; // for the driver
		input data_in,addr; // for the monitor
		input memWE, ldMAR;
	endclocking

	modport TEST (clocking cb, output rst); // asynch. rst
	modport DUT (output data_in, addr, memWE,ldMAR, input data_out, rst, clk);
	modport MONITOR (clocking cb); 

endinterface 
