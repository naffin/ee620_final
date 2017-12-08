package svm_factory_pkg;
	import svm_component_wrapper_pkg::*;
	import svm_component_pkg::*;
class svm_factory;
	//Assoc. array from string to svm_component_wrapper handle
	static svm_component_wrapper m_type_names[string];
	
	static svm_factory m_inst; // Handle to singleton

	static function svm_factory get();
		if (m_inst == null) m_inst = new();
		return m_inst;
	endfunction

	static function void register(svm_component_wrapper c);
		m_type_names[c.get_type_name()] = c; // put object into assoc array
	endfunction
	
	static function svm_component get_test();
		string name;
		svm_component_wrapper test_wrapper;
		svm_component test_comp;

		if (!$value$plusargs("TESTNAME=%s", name)) begin
			$display("FATAL +TESTNAME not found");
			$finish;
		end	
		$display("%m found +TESTNAME=%s", name);
		test_wrapper = svm_factory::m_type_names[name];
		$cast (test_comp, test_wrapper.create_object(name));
		return test_comp;
	endfunction
endclass // svm_factory 
endpackage
