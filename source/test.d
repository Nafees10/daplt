module test;

import daplt.daplt;

import std.stdio,
			 std.string,
			 std.format,
			 core.runtime,
			 core.memory;

version (test){
	extern (C) void unload(){
		Runtime.terminate;
	}

	extern (C) PObj init(){
		assert(Runtime.initialize);
		return moduleCreate!(mixin(__MODULE__))("daplt").obj;
	}

	@PExport void println(string a, string b = null){
		if (a)
			write(a);
		if (b)
			write(b);
		writeln();
	}

	@PExport string mutateString(string s){
		return format!"mutated %s"(s);
	}
}
