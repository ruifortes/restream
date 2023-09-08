open ReStream_Source

let make = (src :readable<'a>, delay: int) :readable<'a> => {

	let timeoutId: ref<option<timeoutId>> = ref(None)
	let readPending = ref(false)
	
	let rec getNext = (cb) => {

		if(!readPending.contents) {

			readPending := true

			src(Pull(payload => {
				readPending := false

				switch (timeoutId.contents) {
					| Some(id) => clearTimeout(id)
					| None => ()
				}		

				switch payload {
					| Data(_) => {
							timeoutId := Some(setTimeout(() => cb(payload), delay) )
							getNext(cb)
						}
					| End | Error(_) => cb(payload)
				}

			}))
		}
	}

	(sig :signal<'a>) => {
		switch sig {
			| Pull(cb) => getNext(cb)
			| Abort => src(Abort)	
			}
	}

}
