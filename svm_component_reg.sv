package svm_component_registry_pkg;
	import svm_component_pkg::*;
	import svm_component_wrapper_pkg::*;
	import svm_factory_pkg::*;
class svm_component_registry #(type T=svm_component, string Tname="<unknown>")
								 extends svm_component_wrapper;
	typedef svm_component_registry #(T, Tname) this_type; // use singleton pattern
	local static this_type me = get(); // Handle to singleton

	static function this_type get();
		if (me == null) begin
			svm_factory f = svm_factory::get();
			me = new();
			f.register(me);
		end

	endfunction
	
	virtual function string get_type_name();
		return Tname;
	endfunction

	virtual function svm_component create_object(string name="");
		T obj;
		obj = new();
		return obj;
	endfunction

	static function T create(string name);
		create = new();
	endfunction

endclass // svm_component_registry
endpackage
