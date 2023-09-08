open Test

module S = ReStream

testAsync("buffer", (done) => {


	let src2 = Belt.Array.make(10, ())
		-> S.fromArray
		-> S.asyncMap((v, cb) => {
			v -> Test_Utils.rndDelay(~min=160, ~max=160, cb)
		})

	let arr = Belt.Array.range(1, 10)

	let result = [
		Belt.Array.range(1, 3) -> Belt.Array.map(v => "#" ++ Js.Int.toString(v)),
		Belt.Array.range(4, 6) -> Belt.Array.map(v => "#" ++ Js.Int.toString(v)),
		Belt.Array.range(7, 9) -> Belt.Array.map(v => "#" ++ Js.Int.toString(v)),
		Belt.Array.range(10, 10) -> Belt.Array.map(v => "#" ++ Js.Int.toString(v)),
		]

	let fail1 = ref(false)

	S.fromArray(arr)
	-> ReStream_Utils.checkStep(() => fail1 := true)
	-> S.asyncMap((v, cb) => {
			let newValue = "#" ++ Js.Int.toString(v)
			newValue -> Test_Utils.rndDelay(~min=50, ~max=50, cb)
		})
	-> S.buffer(src2)
	// -> S.log
	-> S.collect(res => {
		switch res {
			| Ok(arr) => {
				Js.log(arr)
					// Assert.boolEqual(~message="must not call Pull before receiving payload", fail1.contents, false)
					// Assert.arraySameItems(~message="result array has same items", arr, result)
					done()
				}
			| Error(_) => fail()
			}
		})

})