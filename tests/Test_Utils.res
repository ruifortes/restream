module S = ReStream

let rndDelay = (~min=0, ~max=500, ~delays=? , val: 'a, cb: 'a => unit) :unit => {
	let delay = Js.Math.random_int(min, max)
	switch delays {
		| Some(delaysArray) => {
				delaysArray -> Js.Array2.push(delay) -> ignore
			}
		| None => ()
	}
	let _ = Js.Global.setTimeout(() => val -> cb, delay)
}

let asyncIteratorFromArray = %raw(`
  async function* (arr, delay = 200) {

		let delayValue = val => {
			return new Promise((resolve, reject) => {
				setTimeout(() => {
					resolve(val)
				}, delay)
			})
		}

		for await (const v of arr) {
			yield await delayValue(v)
		}
  }
`)


let testReadableWebStream = %raw(`
  async function (stream) {
		try {
			for await (const chunk of stream) {
				// console.log(Buffer.from(chunk).toString());
			}
			return true
		} catch {
			return false
		}
  }
`)


// let actionable_testSource = (actionable: S.actionable<'a>, steps: array<('a, int)>) => {

// 	let rec step = () => {
// 		switch steps -> Js.Array2.shift {
// 			| Some(v, d) => {
// 					let _ = Js.Global.setTimeout(() => {
// 						actionable(Push(v))
// 						step()
// 					}, d)
// 				}
// 			| None => actionable(Close)
// 		}
// 	}

// 	step()
// }

let createAsyncTestSource = (arr :array<('a, int)>) => {

	let values = arr -> Belt.Array.map(((v, _)) => v)
	let delays = arr -> Belt.Array.map(((_, d)) => d)
	
	let index = ref(-1)

	S.fromArray(values)
	-> S.asyncMap((v, cb) => {
		let i = ReStream_Utils.incrementRef(index)
		Js.Global.setTimeout(() => {
			cb(values[i])
		}, delays[i])
		-> ignore
	})

}


