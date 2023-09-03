module test;

import daplt.daplt;
import std.stdio,
			 std.string;

version (test){
	extern (C) PObj init(){
		return moduleCreate!(mixin(__MODULE__))("daplt").obj;
	}

	@PExport int length(string a, string b = null){
		return cast(int)(a.length + b.length);
	}
}
