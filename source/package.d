module daplt;

import plt = daplt.plt;

import std.algorithm;

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

/// if a type is some plt.PltObject wrapping class
private template IsPltWrapper(T){
	enum IsPltWrapper = __traits(hasMember, T, "obj") &&
		is (typeof(__traits(getMember, T, "obj")) == plt.PltObject);
}

/// A plutonium value (wrapper around the actual object)
struct PObj{
	plt.PltObject obj;

	/// Read a value
	auto get(T)(){
		static if (is (T == int) || is (T == uint)){
			return obj.i;
		}else static if (is (T == long) || is (T == ulong)){
			return obj.l;
		}else static if (is (T == bool)){
			return cast(bool)obj.i;
		}else static if (is (T == string)){
			// TODO read string
		}else static if (is (T == double) || is (T == float) || is (T == real)){
			return obj.f;
		}else static if (is (T == void*)){ // sad :(
			return obj.ptr;
		}else static if (is (T == PFunc)){
			return cast(PFunc)(obj.ptr);
		}else static if (IsPltWrapper!T){
			return T(obj);
		}
	}

	/// Returns: PObj created from a type
	static PObj from(T)(T val){
		static if (is (T == PObj)){
			return val;
		}static if (is (T == plt.PltObject)){
			return PObj(val);
		}else static if (is (T == uint) || is (T == ulong)){
			static assert(false, "Plutonium doesnt do unsigned 32 or 64 bit");
		}else static if (is (T == int) ||
				is (T == short) || is (T == ushort) ||
				is (T == byte) || is (T == ubyte) ||
				is (T == bool)){
			plt.PltObject o;
			o.i = val;
			return PObj(obj);
		}else static if (is (T == long)){
			plt.PltObject o;
			o.l = val;
			return PObj(o);
		}else static if (is (T == string)){
			return PObj(plt.allocStrByLength(val.ptr, val.length));
		}else static if (is (T == double) || is (T == float)){
			plt.PltObject o;
			o.f = val;
			return PObj(o);
		}else static if (is (T == void*)){ // sad :(
			plt.PltObject o;
			o.ptr = val;
			return PObj(o);
		}else static if (is (T == PFunc)){
			plt.PltObject o;
			o.ptr = cast(void*)val;
			return PObj(o);
		}else static if (IsPltWrapper!T){
			return val.obj;
		}
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
	plt.PltObject obj;

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
	plt.PltObject obj;

	/// creates a new ByteArray in plutonium memory
	/// Returns: new PBArray
	static PBArray alloc(){
		return PBArray(plt.allocBytearray);
	}

	/// appends to end
	void append(ubyte val){
		plt.btPush(obj, val);
	}

	/// remove past byte
	/// Returns: true if done, false if was empty
	bool reduce(){
		plt.PltObject dummy;
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
	plt.PltObject obj;
}

/// A plutonium module
struct PModule{
	plt.PltObject obj;
}

/// A plutonium Class
struct PClass{
	plt.PltObject obj;
}

/// A plutonium Class Instance
struct PInst{
	plt.PltObject obj;
}
