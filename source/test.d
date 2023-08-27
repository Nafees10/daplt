module test;

import daplt;
import std.stdio,
			 std.string;

version (test){
	extern (C) PObj init(){
		writeln("init called");
		PModule mod = PModule.alloc("test");
		mod.add("println", PCallable("println", &println).to!PObj);
		return mod.obj;
	}

	extern (C) PObj println(PObj* argv, int argc){
		foreach (i; 0 .. argc)
			write(argv[i].to!string);
		writeln();
		return PNull;
	}
}
