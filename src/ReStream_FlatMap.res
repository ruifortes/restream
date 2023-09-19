open ReStream_Source

let makeSync = (src :readable<'a>, mapper :('a) => array<'b>) :readable<'b> => {

	src
	-> ReStream_Transform_Map.makeSync(mapper)
	-> ReStream_Transform_Map.makeSync(arr => ReStream_Source.fromArray(arr))
	-> ReStream_Through_Mix.make(~parallel = 1)

}

let makeAsync = (src :readable<'a>, mapper :('a, array<'b> => unit) => unit) :readable<'b> => {

	src
	-> ReStream_Transform_Map.makeAsync(mapper)
	-> ReStream_Transform_Map.makeSync(arr => ReStream_Source.fromArray(arr))
	-> ReStream_Through_Mix.make(~parallel = 1)

}