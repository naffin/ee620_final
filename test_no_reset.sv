`define svm_component_utils(T) \
	typedef svm_component_registry #(T, `"T`") type_id; \
	virtual function string get_type_name(); \
		return `"T`"; \
	endfunction

package Test_no_reset_pkg;
   import Environment_pkg::*;
   import svm_component_registry_pkg::*;
   import svm_component_pkg::*;
   import driver_cbs_scb_pkg::*;
   import driver_cbs_no_rst_pkg::*;
   import Coverage_pkg::*;
   import Transaction_pkg::*;
class Test_no_reset extends svm_component;
	Environment env;
	`svm_component_utils(Test_no_reset)
   
	function new();
		$display("%m");
		env = new();
	endfunction 

	task run_test();
		$display("%m");
		env.gen_cfg();
		env.build();
		begin
		    Driver_cbs_scb dcs = new(env.scb);
		   Driver_cbs_no_rst dcnr = new();
		   Coverage cov = new();
		   env.check.cov = cov;
		    env.drv.cbs.push_back(dcs);
		    env.drv.cbs.push_back(dcnr);
		   
		   Transaction::reset_prob = 0;
		end
		env.run();
		env.wrap_up();	
	endtask
endclass // Test_no_reset
endpackage
