module plutonium;

import core.stdc.stdio;

enum PltObjectType : char{
	List = 'j',
	Dict = 'a',
	Int = 'i',
	Int64 = 'l',
	Float = 'f',
	Byte = 'm',
	NativeFunc = 'y',
	Module = 'q',
	Str = 's',
	FileStream = 'u',
	Nil = 'n',
	Obj = 'o',
	Class = 'v',
	Bool = 'b',
	Ptr = 'p',
	Func = 'w',
	Coroutine = 'g',
	CoroutineObj = 'z',
	ErrorObj = 'e',
	ByteArr = 'c'
}

extern (C) struct PltObject{
	union{
		double f;
		long l;
		int i;
		void* ptr;
	}
	char type;
}

extern (C) struct FileObject{
	FILE* fp;
	bool open;
}

alias NativeFunPtr = extern (C) PltObject *function(PltObject*, int);

extern (C){
	PltObject nil;
	PltObject Error;
	PltObject TypeError;
	PltObject ValueError;
	PltObject MathError;
	PltObject NameError;
	PltObject IndexError;
	PltObject ArgumentError;
	PltObject FileIOError;
	PltObject KeyError;
	PltObject OverflowError;
	PltObject FileOpenError;
	PltObject FileSeekError;
	PltObject ImportError;
	PltObject ThrowError;
	PltObject MaxRecursionError;
	PltObject AccessError;
}

extern (C){
	/// Returns: newly allocated dictionary
	PltObject allocDict();

	/// (dictionary, key, bool flag ret)
	/// Returns: value or nil
	PltObject dictGet(PltObject, PltObject, bool*);

	/// (dictionary, key, newValue)
	/// Returns: true if set
	bool dictSet(PltObject, PltObject, PltObject);

	/// Returns: Size of dictionary
	size_t dictSize(PltObject);

	/// Gets an iterator over dictionary
	void* newDictIter(PltObject);

	/// Releases iterator
	void freeDictIter(void*);

	/// Advances dict iterator
	void advanceDictIter(PltObject, void**);

	/// Sets value at iterator
	void setDictIterValue(void*, PltObject);

	/// Returns: value in dictionary at iterator
	PltObject getDictIterValue(void*);

	/// Returns: key in dictionary at iterator
	PltObject getDictIterKey(void*);

	/// Returns: newly allocated byteArray
	PltObject allocBytearray();

	/// Pushes a ubyte at end of byteArray
	void btPush(PltObject, ubyte);

	/// Pops a ubyte from end of a byteArray
	/// Returns: false if byteArray was empty
	bool btPop(PltObject, PltObject*);

	/// Returns: number of bytes in a byteArray
	size_t btSize(PltObject);

	/// Resize byteArray to size
	void btResize(PltObject, size_t);

	/// byteArray as an array of ubytes...
	ubyte* btAsArray(PltObject);

	//Plutonium list
	PltObject allocList();
	void listPush(PltObject, PltObject);
	bool listPop(PltObject, PltObject*);
	size_t listSize(PltObject);
	void listResize(PltObject, size_t);
	PltObject* listAsArray(PltObject);

	//Module
	PltObject allocModule(const char*);
	void addModuleMember(PltObject, const char*, PltObject);

	//Klass
	PltObject allocKlass(const char*);
	void klassAddMember(const char*, PltObject);
	void klassAddPrivateMember(const char*, PltObject);

	//Klass Objects
	PltObject allocObj(PltObject);
	void objAddMember(const char*, PltObject);
	void objAddPrivateMember(const char*, PltObject);
	bool objGetMember(const char*, PltObject*);
	bool objSetMember(const char*, PltObject);

	//Native Function
	PltObject PObjFromNativeFun(const char*, NativeFunPtr);

	//Native Method
	PltObject PObjFromNativeMethod(const char*, NativeFunPtr, PltObject);

	//ErrObject
	PltObject Plt_Err(PltObject, const char*);

	//String
	PltObject allocStr(const char*);
	size_t strLength(PltObject);
	const(char)* strAsCstr(PltObject);
	const(char)* strResize(PltObject);
	//Conversions
	PltObject PObjFromInt(int);
	PltObject PObjFromInt64(long);
	PltObject PObjFromDouble(double);
	PltObject PObjFromByte(ubyte);
	PltObject PObjFromBool(bool);
	void foo();
}

unittest{
	import std.stdio;
	writeln("helo");
}
