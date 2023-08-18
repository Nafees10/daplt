module daplt;

import plt = daplt.plt;

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
		}
	}
}
