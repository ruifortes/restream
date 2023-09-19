open ReStream_Source

let make = (src :readable<'a>, delay: int) :readable<'a> => {

	let timedout = ref(true)

	let startTimeout = () => {
		timedout := false
		setTimeout(() => {
			timedout := true
		}, delay) -> ignore
	}
	
	let rec getNext = cb => {

			src(Pull(payload => switch payload {
					| Data(_) => switch timedout.contents {
							| true => {
									startTimeout()
									cb(payload)
								}
							| false => getNext(cb)
						}
					| End | Error(_) => cb(payload)
				}
			))

	}

	let readable = (sig :signal<'a>) => {
		switch sig {
			| Pull(cb) => getNext(cb)
			| Abort => src(Abort)	
			}
	}

	readable

}

