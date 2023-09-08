open Test

module S = ReStream

testAsync("abortable, not aborting", (done) => {

	let arr = Belt.Array.range(1, 4)
	let fail1 = ref(false)

	let (abortable, abort) = S.abortable()

	// Js.Global.setTimeout(abort, 200) -> ignore

	S.fromArray(arr)
	-> ReStream_Utils.checkStep(() => fail1 := true)
	-> S.asyncMap((v, cb) => {
			("#" ++ Js.Int.toString(v)) -> Test_Utils.rndDelay(~min=50, ~max=50, cb)
		})
	-> abortable
	// -> S.log
	-> S.collect(res => {
		switch res {
			| Ok(arr) => {
					Assert.boolEqual(~message="must not call Pull before receiving payload", fail1.contents, false)
					Assert.arrayDeepEqual(~message="results match", arr, ["#1", "#2", "#3", "#4"])
					done()
				}
			| Error(_) => fail()
			}
		})

})

testAsync("abortable, aborting", (done) => {

	let arr = Belt.Array.range(1, 10)
	let fail1 = ref(false)

	let (abortable, abort) = S.abortable()

	Js.Global.setTimeout(abort, 200) -> ignore

	S.fromArray(arr)
	-> ReStream_Utils.checkStep(() => fail1 := true)
	-> S.asyncMap((v, cb) => {
			("#" ++ Js.Int.toString(v)) -> Test_Utils.rndDelay(~min=50, ~max=50, cb)
		})
	-> abortable
	// -> S.log
	-> S.collect(res => {
		switch res {
			| Ok(arr) => {
					Assert.boolEqual(~message="must not call Pull before receiving payload", fail1.contents, false)
					Assert.arrayDeepEqual(~message="results match", arr, ["#1", "#2", "#3", "#4"])
					done()
				}
			| Error(_) => fail()
			}
		})

})