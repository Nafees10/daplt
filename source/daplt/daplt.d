module daplt.daplt;

import plt = daplt.plt;

import std.algorithm,
			 std.string;

/// Object type
alias PType = plt.PltObjectType;
/// nill return value
alias PNull = plt.nil;

/// Error values
struct PError{
	static alias Error = plt.Error;
	static alias Type = plt.TypeError;
	static alias Value = plt.ValueError;
	static alias Math = plt.MathError;
	static alias Name = plt.NameError;
	static alias Index = plt.IndexError;
	static alias Argument = plt.ArgumentError;
	static alias FileIO = plt.FileIOError;
	static alias Key = plt.KeyError;
	static alias Overflow = plt.OverflowError;
	static alias FileOpen = plt.FileOpenError;
	static alias FileSeek = plt.FileSeekError;
	static alias Import = plt.ImportError;
	static alias Throw = plt.ThrowError;
	static alias MaxRecursion = plt.MaxRecursionError;
	static alias Access = plt.AccessError;
}

/// Function callable by plutonium code
alias PFunc = plt.NativeFunPtr;

alias PObj = plt.PltObject;

/// if a type is some PObj wrapping class
private template IsPltWrapper(T){
	enum IsPltWrapper = __traits(hasMember, T, "obj") &&
		is (typeof(__traits(getMember, T, "obj")) == PObj);
}

/// Read a value by type from a PObj
/// Returns: the value
T to(T : int)(PObj obj){
	assert (obj.type == PType.Int);
	return obj.i;
}
T to(T : long)(PObj obj){
	assert (obj.type == PType.Int64);
	return obj.l;
}
T to(T : bool)(PObj obj){
	assert (obj.type == PType.Bool);
	return cast(bool)obj.i;
}
T to(T : string)(PObj obj){
	assert (obj.type == PType.Str);
	return cast(string)fromStringz(cast(char*)plt.strAsCstr(obj));
}
T to(T : double)(PObj obj){
	assert (obj.type == PType.Float);
	return obj.f;
}
T to(T : void*)(PObj obj){
	return obj.ptr;
}
T to(T, From : PObj)(PObj obj) if (IsPltWrapper!T){
	return T(obj);
}
/*T to(T : PFunc)(PObj obj){
	assert (obj.type == PType.NativeFunc);
	return cast(PFunc)(obj.ptr);
}
T to(T : PDict)(PObj obj){
	return T(obj);
}
T to(T : PBArray)(PObj obj){
	return T(obj);
}
T to(T : PList)(PObj obj){
	return T(obj);
}
T to(T : PModule)(PObj obj){
	return T(obj);
}
T to(T : PClass)(PObj obj){
	return T(obj);
}
T to(T : PClassObj)(PObj obj){
	return T(obj);
}
T to(T : PCallable)(PObj obj){
	return T(obj);
}*/

PObj to(To : PObj, T)(T val){
	static if (is (T == PObj)){
		return val;
	}else static if (is (T == uint) || is (T == ulong)){
		static assert(false, "Plutonium doesnt do unsigned 32 or 64 bit");
	}else static if (is (T == int) ||
			is (T == short) || is (T == ushort) ||
			is (T == byte) || is (T == ubyte) ||
			is (T == bool)){
		PObj o;
		o.i = val;
		o.type = PType.Int;
		return PObj(obj);
	}else static if (is (T == long)){
		PObj o;
		o.l = val;
		o.type = PType.Int64;
		return PObj(o);
	}else static if (is (T == string)){
		return plt.allocStrByLength(val.ptr, val.length);
	}else static if (is (T == double) || is (T == float)){
		PObj o;
		o.f = val;
		o.type = PType.Float;
		return PObj(o);
	}else static if (is (T == void*)){ // sad :(
		PObj o;
		o.ptr = val;
		o.type = PType.Ptr;
		return PObj(o);
	}else static if (IsPltWrapper!T){
		return val.obj;
	}else{
		static assert (false, "Daplt does not support " ~ To.stringof);
	}
}

/// daplt exception
class DapltException : Exception{
	this (string msg = null){
		super(msg);
	}
}

/// A plutonium dictionary
/// TODO implement iteration
struct PDict{
	PObj obj;

	this (PObj obj){
		assert (obj.type == PType.Dict);
		this.obj = obj;
	}

	/// creates a new dictionary in plutonium memory
	/// Returns: new PDict
	static PDict alloc(){
		return PDict(plt.allocDict);
	}

	/// gets value against a key
	/// Throws: DapltException if key not found
	/// Returns: value against key
	PObj get(T)(T key){
		PObj keyObj = PObj.from(key);
		bool status = true;
		auto ret = PObj(dictGet(obj, keyObj.obj, &status));
		if (!status)
			throw new DapltException("key object not found in dictionary");
		return ret;
	}

	/// Sets value against an existing key.
	/// Returns: true if done, false if key does not exist
	bool set(K, V)(K key, V val){
		PObj keyObj = PObj.from(key), valObj = PObj.from(val);
		return plt.dictSet(obj, keyObj, valObj);
	}

	/// Adds a new key-value pair
	/// Returns: false if key already exists
	bool add(K, V)(K key, V val){
		PObj keyObj = PObj.from(key), valObj = PObj.from(val);
		return plt.dictAdd(obj, keyObj, valObj);
	}

	/// number of values stored in dictionary
	size_t count(){
		return plt.dictSize(obj);
	}
}

/// A plutonium byte array
struct PBArray{
	PObj obj;

	this (PObj obj){
		assert (obj.type == PType.ByteArr);
		this.obj = obj;
	}

	/// creates a new ByteArray in plutonium memory
	/// Returns: new PBArray
	static PBArray alloc(){
		return PBArray(plt.allocBytearray);
	}

	/// appends to end
	void append(ubyte val){
		plt.btPush(obj, val);
	}

	/// remove last byte
	/// Returns: true if done, false if was empty
	bool reduce(){
		PObj dummy;
		return plt.btPop(obj, &dummy);
	}

	/// size
	@property size_t length(){
		return plt.btSize(obj);
	}
	/// ditto
	@property size_t length(size_t newLength){
		plt.btResize(obj, newLength);
		return plt.btSize(obj);
	}

	/// Returns: as an array of ubyte
	@property ubyte[] array(){
		return plt.btAsArray(obj)[0 .. length];
	}
}

/// A plutonium list
struct PList{
	PObj obj;

	this (PObj obj){
		assert (obj.type == PType.List);
		this.obj = obj;
	}

	/// Creates new list in plutonium memory
	/// Returns: newly allocated plutonium list
	static PList alloc(){
		return PList(plt.allocList);
	}

	/// Appends a value
	void append(PObj val){
		plt.listPush(obj, val);
	}

	/// Removes last element
	/// Returns: true if done, false if list was empty
	bool reduce(){
		PObj dummy;
		return plt.listPop(obj, &dummy);
	}

	/// list size
	@property size_t length(){
		return plt.listSize(obj);
	}
	/// ditto
	@property size_t length(size_t newLength){
		plt.listResize(obj, newLength);
		return plt.listSize(obj);
	}

	/// Returns: copy of PList as an array of PObj
	PObj[] array(){
		return plt.listAsArray(obj)[0 .. length];
	}
}

/// A plutonium module
struct PModule{
	PObj obj;

	this (PObj obj){
		assert (obj.type == PType.Module);
		this.obj = obj;
	}

	/// Create a module in plutonium memory
	/// Returns: newly allocated module
	static PModule alloc(string name){
		return PModule(plt.allocModule(name.ptr, name.length));
	}

	/// Adds a member to this module
	void add(string name, PObj member){
		plt.addModuleMember(obj, name.ptr, name.length, member);
	}
}

/// A plutonium Class
struct PClass{
	PObj obj;

	this (PObj obj){
		assert (obj.type == PType.Class);
		this.obj = obj;
	}

	/// Allocates a new class in plutonium memory. This is a class not an object
	/// Returns: newly allocated class
	static PClass allocate(string name){
		return PClass(plt.allocKlass(name.ptr, name.length));
	}

	/// adds a member
	void add(string name, PObj member, bool pub = true){
		if (pub){
			plt.klassAddMember(obj, name.ptr, name.length, member);
			return;
		}
		plt.klassAddPrivateMember(obj, name.ptr, name.length, member);
	}
}

/// A plutonium Class Instance
struct PClassObj{
	PObj obj;

	this (PObj obj){
		assert (obj.type == PType.Obj);
		this.obj = obj;
	}

	/// Allocates an instance of a class in plutonium memory
	/// Returns: newly allocated object
	static PClassObj alloc(PObj classObj){
		return PClassObj(plt.allocObj(classObj));
	}

	/// adds a member by name
	void add(string name, PObj member, bool pub = true){
		if (pub){
			plt.objAddMember(obj, name.ptr, name.length, member);
			return;
		}
		plt.objAddPrivateMember(obj, name.ptr, name.length, member);
	}

	/// gets a member by name
	/// Throws: DapltException if member does not exist
	/// Returns: member PObj
	PObj get(string name){
		PObj ret;
		if (!plt.objGetMember(obj, name.ptr, name.length, &ret))
			throw new DapltException("member " ~ name ~ " does not exist in object");
		return ret;
	}

	/// sets member by name
	/// Returns: true if done, false if does not exist
	bool set(string name, PObj val){
		return plt.objSetMember(obj, name.ptr, name.length, val);
	}
}

/// a callable object
struct PCallable{
	PObj obj;

	this (PObj obj){
		assert (obj.type == PType.NativeFunc || obj.type == PType.Func);
	}
	this (string name, PFunc func){
		obj = plt.PObjFromNativeFun(name.ptr, name.length, func);
	}
	this (string name, PFunc func, PClass classObj){
		obj = plt.PObjFromNativeMethod(name.ptr, name.length, func, classObj.obj);
	}

	/// Calls this callable object.
	/// Throws: DapltException if some error (not valid callable object)
	/// Returns: `PNull` or return value
	PObj call(PObj[] args){
		PObj ret;
		if (plt.vm_callObject(&obj, args.ptr, cast(int)args.length, &ret))
			return ret;
		throw new DapltException("vm_callObject returned false");
	}

	/// ditto
	PObj opCall(Types...)(Types args){
		PObj[args.length] argsArr;
		static foreach (i, arg; args)
			argsArr[i] = arg.pobjOf;
		PObj ret;
		if (plt.vm_callObject(&obj, argsArr.ptr, cast(uint)args.length, &ret))
			return ret;
		throw new DapltException("vm_callObject returned false");
	}
}
