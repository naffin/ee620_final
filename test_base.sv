`define svm_component_utils(T) \
	typedef svm_component_registry #(T, `"T`") type_id; \
	virtual function string get_type_name(); \
		return `"T`"; \
	endfunction

package Test_base_pkg;
   import Environment_pkg::*;
   import svm_component_registry_pkg::*;
   import svm_component_pkg::*;
   import driver_cbs_scb_pkg::*;

class Test_base extends svm_component;
	Environment env;
	`svm_component_utils(Test_base)
	
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
		    env.drv.cbs.push_back(dcs);
		end
		env.run();
		env.wrap_up();	
	endtask
endclass // Test_base
endpackage
