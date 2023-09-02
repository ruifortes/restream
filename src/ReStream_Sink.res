module Promise = Js.Promise
exception PromiseError(string)

open ReStream_Source

let drain = (~onEnd :Belt.Result.t<'b, string> => unit = _ => (), src: readable<'a>) => {

	let ended = ref(false)

	let rec cb = (payload: payload<'a>) => {
		switch payload {
		| Data(v)=> {
				src(Pull(cb))
				// Js.Global.setTimeout(() => src(Pull(cb)) ,0) -> ignore
			}
		| End => {
				if (ended.contents == false) {
					ended := true
					onEnd(Ok())
				}
			}
		| Error(err) => onEnd(Error(err))
		}
	}

	src(Pull(cb))

}


let abortableDrain = (~onEnd :Belt.Result.t<'b, string> => unit = _ => (), src: readable<'a>) => {

	let (abortable, abort) = ReStream_Through.abortable()

	src -> abortable -> drain(~onEnd)

	abort

}


let drainToPromise = (src: readable<'a>): Promise.t<'b> => {
	Promise.make((~resolve, ~reject) => {
		drain(src, ~onEnd = ret => {
			switch ret {
				| Belt.Result.Ok(_unit) => resolve(. _unit)
				| Belt.Result.Error(err) => reject(. PromiseError(err))
			}
		})
		-> ignore
	})
}


let collect = (src: readable<'a>, cb: Belt.Result.t<array<'a>, string> => unit): unit => {
	src
	-> ReStream_Group.make(0)
	-> ReStream_Through.tap(arr => Belt.Result.Ok(arr) -> cb)
	-> drain(~onEnd = res => switch res {
			| Error(err) => Belt.Result.Error(err) -> cb
			| _ => () 
		})
	-> ignore
}


let collectToPromise = (src: readable<'a>) :Promise.t<array<'a>> => {
	Promise.make((~resolve, ~reject) => {	
		collect(src, ret => {
			switch ret {
				| Belt.Result.Ok(ret) => resolve(. ret)
				| Belt.Result.Error(err) => reject(. PromiseError(err))
			}
		})
	})
}

