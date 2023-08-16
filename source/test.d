module test;

import plutonium;
import std.stdio,
			 std.string;

version (test){
	extern (C) PltObject init(){
		writeln("init called");
		auto mod = allocModule("test");
		addModuleMember(mod, "println\0", PObjFromNativeFun(
					"println\0", &println));

		return mod;
	}

	extern (C) PltObject println(PltObject* argv, int argc){
		foreach (i; 0 .. argc)
			write(fromStringz(strAsCstr(argv[i])));
		writeln();
		return nil;
	}
}
