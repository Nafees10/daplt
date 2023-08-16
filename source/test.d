module test;

import plutonium;
import std.stdio;

version (test){
	extern (C) PltObject init(){
		writeln("init called");
		auto mod = allocModule("test");
		return mod;
	}
}
