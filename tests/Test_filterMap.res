open Test

module S = ReStream


testAsync("filterMap", (done) => {

	let arr = Belt.Array.range(1, 10)
	let fail1 = ref(false)

	S.fromArray(arr)
	-> ReStream_Utils.checkStep(() => fail1 := true)
	-> S.asyncMap((v, cb) => {
			v -> Test_Utils.rndDelay(~min=10, ~max=50, cb)
		})
	-> S.filterMap(v => {
				if(mod(v, 2) == 0) {
					Some(v + 10)
				} else {
					None
				}
			})
	// -> S.log
	-> S.collect(res => {
		switch res {
			| Ok(arr) => {
					Assert.boolEqual(~message="must not call Pull before receiving payload", fail1.contents, false)
					Assert.arrayDeepEqual(~message="results match", arr, [12, 14, 16, 18, 20])
					done()
				}
			| Error(err) => fail()
			}
		})

})


