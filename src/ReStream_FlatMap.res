open ReStream_Source

let makeSync = (src :readable<'a>, mapper :('a) => array<'b>) :readable<'b> => {

	src
	-> ReStream_Transform.map(mapper)
	-> ReStream_Transform.map(arr => ReStream_Source.fromArray(arr))
	-> ReStream_Through_Mix.make(~parallel = 1)

}

let makeAsync = (src :readable<'a>, mapper :('a, array<'b> => unit) => unit) :readable<'b> => {

	src
	-> ReStream_Transform.asyncMap(mapper)
	-> ReStream_Transform.map(arr => ReStream_Source.fromArray(arr))
	-> ReStream_Through_Mix.make(~parallel = 1)

}