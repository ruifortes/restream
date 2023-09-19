open ReStream_Source

let through = (src :readable<'a>) :readable<'a> => {
	let readable = (sig :signal<'a>) => {

		switch sig {
			| Pull(cb) => {
					src(Pull(payload => {
						Js.log2("log:", payload)
						cb(payload)
					}))
				}
			| Abort => src(Abort)
			}
		}

	readable
}

let tap = (src :readable<'a>, fn :'a => unit) :readable<'a> => {
	src -> ReStream_Transform_Map.makeSync(val => {
		fn(val)
		val
	})
}

let log = tap(_ , x => Console.log(x))

let take = (src :readable<'a>, max :int) => {
	let counter = ref(0)

	let readable = (sig :signal<'a>) => {
		let curr = counter.contents
		switch sig {
			| Pull(cb) when curr >= max => {
					src(Abort)
					cb(End)
				}
			| Pull(cb) => {
					counter := curr + 1
					src(Pull(cb))
				}
			| Abort => src(Abort)
			}
		}

	readable
}


let abortable = () => {

	let aborted = ref(false)

	let abort = () => {
		aborted := true
	}

	let through = (src :readable<'a>) => {
		
		let readable = (sig :signal<'a>) => {
			switch sig {
				| Pull(cb) => {
						if(aborted.contents) {
							src(Abort)
							cb(End)
						} else {
							src(Pull(cb))
						}
					}
				| Abort => src(Abort)
				}
		}

		readable
	}

	(through, abort)

}


let timeout = (src :readable<'a>, max :int) => {
		let timerId = ref(None)

		let readable = (sig :signal<'a>) => {
			switch sig {
				| Pull(cb) => {
						timerId := Some(setTimeout(() => {
							src(Abort)
							cb(Error("timeout exceded"))
						}, max))

						src(Pull(payload => {
							switch timerId.contents {
								| Some(id) => clearTimeout(id)
								| None => ()
							}
							cb(payload)
						}))
					}
				| Abort => src(Abort)
				}
		}

		readable
	}