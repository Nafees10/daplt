# daplt

D Language wrapper to Plutonium for creating modules.

## Getting Started

Add to project using:
```bash
dub add daplt
```

and create an `extern (C) init` and `unload` function like:
```D
import daplt.daplt;
import core.runtime;
extern (C) PObj init(){
	Runtime.initialize;
	return moduleCreate!(mixin(__MODULE__))("moduleName").obj;
}
extern (C) void unload(){
	Runtime.terminate;
}
```

## Exporting Functions

Use the `@PExport` attribute with a function definition to export it:
```D
@PExport string concat(string a, string b){
	return a ~ b;
}
```

daplt will handle the type conversion checks, default parameters, and
conversion of return type.

## Data Types

Use `PObj.get!DType` to get D type value from a Plutonium value.
This can throw a `DapltException` since actual type of PObj cannot be determined
at compile time.

Use `DValue.to!PObj` to get a Plutonium value from a D value. This can result in
a `static assert(false)` if the source data type is not supported.

|			Plutonium Type			|			D Type		|
|-------------------------|---------------|
|	`Int`										|	`int`					|
|	`Int64`									|	`long`				|
|	`Bool`									|	`bool`				|
|	`Str`										|	`string`			|
|	`Float`									|	`double`			|
|	`Ptr`										|	`void*`				|
|	`Ptr`										|	`void*`				|
|	`Dict`									|	`PDict`				|
|	`ByteArr`								|	`PBArray`			|
|	`List`									|	`PList`				|
|	`Module`								|	`PModule`			|
|	`Class` or `Klass`			|	`PClass`			|
|	`Obj`										|	`PClassObj`		|
|	`Func` or `NativeFunc`	|	`PCallable`		|

See `source.daplt.daplt` for documentation on `PList`, `PClass`, `PClassObj`,
and `PCallable`
