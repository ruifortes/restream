open Test

module S = ReStream

let testData_A = [
	(1, 100),
	(2, 100),
	(3, 100),
	(4, 500),
	(5, 100),
	(6, 100),
	(7, 100),
	(8, 100),
	(9, 100),
	(10, 100),
	(11, 100),
	(12, 100),
	(13, 100),
	(14, 100)
]

testAsync("throttle", ~timeout=15000, (done) => {

	Test_Utils.createAsyncTestSource(testData_A)
	// S.fromArray(Belt.Array.range(1, 10))
	-> S.throttle(300)
	-> S.log
	-> S.collect(res => {
		switch res {
			| Ok(arr) => {
				Js.log2("THE END", arr)
					done()
				}
			| Error(_) => fail()
			}
		})

})


// S.fromArray(Belt.Array.range(1, 10))
// -> S.asyncMap((v, cb) => {
// 		let newValue = "#" ++ Int.toString(v)
// 		newValue -> Test_Utils.rndDelay(~min=100, ~max=1000, cb)
// 	})
// -> S.debounce(500)
// -> S.collect(res => {
// 	switch res {
// 		| Ok(arr) => Js.log(arr)
// 		| Error(_) => ()
// 		}
// })


// S.fromArray(Belt.Array.range(1, 10))
// -> S.asyncMap((v, cb) => {
// 		let newValue = "#" ++ Int.toString(v)
// 		newValue -> Test_Utils.rndDelay(~min=500, ~max=1000, cb)
// 	})
// -> S.asyncMap((v, cb) => {
// 		let newValue = "#" ++ v
// 		newValue -> Test_Utils.rndDelay(~min=50, ~max=500, cb)
// 	})
// -> S.log
// -> S.collect(res => {
// 	switch res {
// 		| Ok(arr) => {
// 			Js.log(arr)
// 				// Assert.boolEqual(~message="must not call Pull before receiving payload", fail1.contents, false)
// 				// Assert.arraySameItems(~message="result array has same items", arr, result)

// 			}
// 		| Error(_) => ()
// 		}
// 	})