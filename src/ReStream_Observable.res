open ReStream_Source

type removeObserver = unit => unit

let make = () => {

	let count = ref(0)

	let aborted = ref(false)

	let observers: Belt.MutableMap.Int.t<callback<'a>> = Belt.MutableMap.Int.make()

	let observe = observer => {

		let k = count -> ReStream_Utils.incrementRef

		observers -> Belt.MutableMap.Int.set(k, observer)

		() => observers -> Belt.MutableMap.Int.remove(k)

	}

	let through = (src :readable<'a>) => {
		
		let readable = (sig :signal<'a>) => {
			switch sig {
				| Pull(cb) => src(Pull(payload => {

						observers -> Belt.MutableMap.Int.forEach((k, obs) => {
							obs(payload)
						})

						cb(payload)
						
					}))
				| Abort => src(Abort)
				}
		}

		readable
	}

	(through, observe: callback<'a> => removeObserver)

}