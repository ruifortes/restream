
exception PromiseError(string)

open ReStream_Source

let drain = (~onEnd :Result.t<'b, string> => unit = _ => (), src: readable<'a>) => {

	let ended = ref(false)

	let rec cb = (payload: payload<'a>) => {
		switch payload {
		| Data(v)=> src(Pull(cb))
		| End => {
				if (ended.contents == false) {
					ended := true
					onEnd(Result.Ok())
				}
			}
		| Error(err) => onEnd(Result.Error(err))
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
	Promise.make((resolve, reject) => {
		drain(src, ~onEnd = ret => {
			switch ret {
				| Result.Ok(_unit) => resolve(. _unit)
				| Result.Error(err) => reject(. PromiseError(err))
			}
		})
	})
}


let collect = (src: readable<'a>, cb: Result.t<array<'a>, string> => unit): unit => {

	let values = []

	src
	-> ReStream_Through.tap(v => values -> Array.push(v))
	-> drain(~onEnd = res => switch res {
			| Error(err) => Result.Error(err) -> cb
			| Ok() => Result.Ok(values) -> cb
		})
		
}


let collectToPromise = (src: readable<'a>) :Promise.t<array<'a>> => {
	Promise.make((resolve, reject) => {	
		collect(src, ret => {
			switch ret {
				| Result.Ok(ret) => resolve(. ret)
				| Result.Error(err) => reject(. PromiseError(err))
			}
		})
	})
}

