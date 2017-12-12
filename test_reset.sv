`define svm_component_utils(T) \
	typedef svm_component_registry #(T, `"T`") type_id; \
	virtual function string get_type_name(); \
		return `"T`"; \
	endfunction

package Test_reset_pkg;
   import Environment_pkg::*;
   import svm_component_registry_pkg::*;
   import svm_component_pkg::*;
   import driver_cbs_scb_pkg::*;
   import Coverage_pkg::*;
   import Transaction_pkg::*;
class Test_reset extends svm_component;
	Environment env;
	`svm_component_utils(Test_reset)
   
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
		   Coverage cov = new();
		   env.check.cov = cov;
		    env.drv.cbs.push_back(dcs);
		   Transaction::reset_prob = 10;
		end
		env.run();
		env.wrap_up();	
	endtask
endclass // Test_reset
endpackage
