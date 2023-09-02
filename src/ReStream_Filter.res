open ReStream_Source

let makeSync = (src :readable<'a>, test :'a => bool) :readable<'a> => {

	let rec getNext = cb
		=> src(Pull(payload
			=> switch payload {
				| Data(val) => {
						if test(val) {cb(payload)}
						else {getNext(cb)}
					}
				| End => cb(End)
				| Error(err) => cb(Error(err))
				}
			))


	(sig :signal<'a>) => {
		switch sig {
			| Pull(cb) => getNext(payload => cb(payload))
			| Abort => src(Abort)
			}
		}	

}


let makeAsync = (src :readable<'a>, tester :('a, bool => unit) => unit) :readable<'a> => {

	let rec getNext = cb
		=> src(Pull(payload
			=> switch payload {
				| Data(val) => {
						tester(val, pass => {
							switch pass {
								| true => cb(Data(val))
								| false => getNext(cb)
							}
						})
					}
				| End => cb(End)
				| Error(err) => cb(Error(err))
				}
			))


	(sig :signal<'a>) => {
		switch sig {
			| Pull(cb) => getNext(payload => cb(payload))
			| Abort => src(Abort)
			}
		}	

}


let makeSyncFilterMap = (src :readable<'a>, test :'a => option<'b>) :readable<'b> => {

	let rec getNext = cb
		=> src(Pull(payload
			=> switch payload {
				| Data(a) => switch test(a) {
						| Some(b) => cb(Data(b))
						| None => getNext(cb)
					}
				| End => cb(End)
				| Error(err) => cb(Error(err))
				}
			))


	(sig :signal<'a>) => {
		switch sig {
			| Pull(cb) => getNext(payload => cb(payload))
			| Abort => src(Abort)
			}
		}

}

let makeAsyncFilterMap = (src :readable<'a>, mapper :('a, option<'b> => unit) => unit) :readable<'b> => {

	let rec getNext = cb
		=> src(Pull(payload
			=> switch payload {
				| Data(val) => {
						mapper(val, (maybeVal :option<'b>) => {
							switch maybeVal {
								| Some(newVal) => cb(Data(newVal))
								| None => getNext(cb)
							}
						})
					}
				| End => cb(End)
				| Error(err) => cb(Error(err))
				}
			))


	(sig :signal<'a>) => {
		switch sig {
			| Pull(cb) => getNext(payload => cb(payload))
			| Abort => src(Abort)
			}
		}	

}

