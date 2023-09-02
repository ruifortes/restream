let incrementRef = (ref: ref<int>) :int => {
	let current = ref.contents
	ref.contents = current + 1
	ref.contents
}

open ReStream_Source

let checkStep = (src :readable<'a>, onError: unit => unit) :readable<'a> => {

	let pendingCallback: ref<option<callback<'a>>> = ref(None)

	(sig :signal<'a>) => {
		switch sig {
			| Pull(cb) => {
					if(pendingCallback.contents -> Js.Option.isSome) {
						Js.log("calling pull before response....")
						onError()
					}
					pendingCallback := Some(cb)
					src(Pull(payload => {
							pendingCallback := None
							cb(payload)
						}))
				}
			| Abort => src(Abort)
			}
		}


}
