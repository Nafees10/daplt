module test;

import daplt.daplt;
import std.stdio,
			 std.string;

version (test){
	extern (C) PObj init(){
		writeln("init called");
		PModule mod = PModule.alloc("test");
		mod.add("println", PCallable("println", &println).to!PObj);
		mod.add("callbackTest", PCallable("callbackTest", &callbackTest).to!PObj);
		return mod.obj;
	}

	extern (C) PObj println(PObj* argv, int argc){
		foreach (i; 0 .. argc)
			write(argv[i].get!string);
		writeln();
		return PNull;
	}

	extern (C) PObj callbackTest(PObj* argv, int argc){
		try{
			auto func = argv[0].get!PCallable;
			return func(5);
		} catch (DapltException e){
			writeln(e.msg);
		}
		return 1.to!PObj;
	}
}
