program automatic test;
	import svm_component_pkg::*;
	import svm_factory_pkg::*;
	import Test_base_pkg::*;
	import Test_reset_pkg::*;
	import Test_no_reset_pkg::*;
   	initial begin
   		svm_component test_obj;
		test_obj = svm_factory::get_test();
		test_obj.run_test();	 
   	end
endprogram
