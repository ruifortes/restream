open ReStream_Source

let tap = (src :readable<'a>, fn :'a => unit) :readable<'a> => {
	src -> ReStream_Transform.map((val :'a) :'a => {
		fn(val)
		val
	})
}

let log = tap(_ , x => Js.log(x))

// let log = src => src -> ReStream_Transform.map(v => {
// 	Js.log(v)
// 	v
// })

let take = (src :readable<'a>, max :int) => {
	let counter = ref(0)

	(sig :signal<'a>) => {
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
}


let abortable = () => {

	let aborted = ref(false)

	let abort = () => {
		aborted := true
	}

	let through = (src :readable<'a>) => {
		
		(sig :signal<'a>) => {
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
	}

	(through, abort)

}


let timeout = (src :readable<'a>, max :int) => {
		let timer = ref(Js.Nullable.null)

		(sig :signal<'a>) => {
			switch sig {
				| Pull(cb) => {
						timer := Js.Nullable.return(Js.Global.setTimeout(() => {
							src(Abort)
							cb(Error(Failure("timeout exceded")))
						}, max))

						src(Pull(payload => {
							Js.Nullable.iter(timer.contents, (. timer) => Js.Global.clearTimeout(timer))
							cb(payload)
						}))
					}
				| Abort => src(Abort)
				}
		}
	}