module daplt.plt;

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

alias NativeFunPtr = extern (C) PltObject function(PltObject*, int);

extern (C) extern __gshared{
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

	/// (dictionary, key, value)
	bool dictAdd(PltObject, PltObject, PltObject);

	/// Returns: Size of dictionary
	size_t dictSize(PltObject);

	/// Gets an iterator over dictionary
	void* newDictIter(PltObject);

	/// Releases iterator
	void freeDictIter(void*);

	/// (map, ptr to iterator)
	/// Advances dict iterator
	void advanceDictIter(PltObject, void**);

	/// (iterator, value)
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

	/// (array, retPtr)
	/// Pops a ubyte from end of a byteArray
	/// Returns: false if byteArray was empty
	bool btPop(PltObject, PltObject*);

	/// Returns: number of bytes in a byteArray
	size_t btSize(PltObject);

	/// Resize byteArray to size
	void btResize(PltObject, size_t);

	/// byteArray as an array of ubytes...
	ubyte* btAsArray(PltObject);

	/// Returns: newly allocated Plutonium List
	PltObject allocList();

	/// (list, value)
	/// Pushes to a Plutonium List
	void listPush(PltObject, PltObject);

	/// (list, retPtr)
	/// Pops from a Plutonium List
	/// Returns: if list was empty
	bool listPop(PltObject, PltObject*);

	/// Returns: size of a Plutonium List
	size_t listSize(PltObject);

	/// Resizes a Plutonium List
	void listResize(PltObject, size_t);

	/// Returns: a Plutonium List as an array of PltObjects
	PltObject* listAsArray(PltObject);

	/// Returns: newly allocated module
	PltObject allocModule(const char*, size_t);

	/// (module, memberName, member)
	/// Adds a member to a module
	void addModuleMember(PltObject, const char*, size_t, PltObject);

	/// Returns: newly allocated Class
	PltObject allocKlass(const char*, size_t);

	/// (Class, memberName, member)
	/// Adds a member with a name to a Class
	void klassAddMember(PltObject, const char*, size_t, PltObject);

	/// (Class, memberName, member)
	/// Adds a private member with a name to a Class
	void klassAddPrivateMember(PltObject, const char*, size_t, PltObject);

	/// Returns: an instance of a Class
	PltObject allocObj(PltObject);

	/// (Class, memberName, member)
	/// Adds a member to a class instance
	void objAddMember(PltObject, const char*, size_t, PltObject);

	/// (Class, memberName, member)
	/// Adds a private member to a class instance
	void objAddPrivateMember(PltObject, const char*, size_t, PltObject);

	/// (Class, memberName, ret ptr)
	/// Gets a member from a class instance
	/// Returns: false if does not exist
	bool objGetMember(PltObject, const char*, size_t, PltObject*);

	/// (Class, memberName, val)
	/// Sets a member in a class instance
	/// Returns: false if does not exist
	bool objSetMember(PltObject, const char*, size_t, PltObject);

	/// (name, func ptr)
	/// Returns: a PltObject against a native function
	PltObject PObjFromNativeFun(const char*, size_t, NativeFunPtr);

	/// (name, function ptr, class)
	/// Returns: a PltObject against a native function binded to a class
	PltObject PObjFromNativeMethod(const char*, size_t, NativeFunPtr, PltObject);

	/// Returns: error object, with message
	PltObject Plt_Err(PltObject, const char*, size_t);

	/// Returns: newly allocated string from a c string
	PltObject allocStr(const char*, size_t);

	/// Returns: newly allocated string from a D string's ptr and length
	PltObject allocStrByLength(const char*, size_t);

	/// Returns: Length of a Plutonium string
	size_t strLength(PltObject);

	/// Returns: Plutonium string as a const c string
	const(char)* strAsCstr(PltObject);

	/// Resizes a plutonium string
	void strResize(PltObject, size_t);

	/// Returns: Plutonium object from int
	PltObject PObjFromInt(int);

	/// Returns: Plutonium object from long
	PltObject PObjFromInt64(long);

	/// Returns: Plutonium object from double
	PltObject PObjFromDouble(double);

	/// Returns: Plutonium object from ubyte
	PltObject PObjFromByte(ubyte);

	/// Returns: Plutonium object from bool
	PltObject PObjFromBool(bool);
}
