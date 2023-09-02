open Test

module S = ReStream

testAsync("group", (done) => {

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
			newValue -> Test_Utils.rndDelay(~min=10, ~max=50, cb)
		})
	-> S.group(3)
	// -> S.log
	-> S.collect(res => {
		switch res {
			| Ok(arr) => {
					Assert.boolEqual(~message="must not call Pull before receiving payload", fail1.contents, false)
					Assert.arraySameItems(~message="result array has same items", arr, result)
					done()
				}
			| Error(err) => fail()
			}
		})

})