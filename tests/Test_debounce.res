open Test

module S = ReStream

let testData_A = [
	(1, 100),
	(2, 100),
	(3, 600),
	(4, 100),
	(5, 100),
	(6, 100),
	(7, 600),
	(8, 100),
	(9, 600),
	(10, 100)
]

testAsync("debounce", ~timeout=15000, (done) => {

	// Console.time("timer2")

	Test_Utils.createAsyncTestSource(testData_A)
	// -> S.tap(v => Console.timeLog("timer2"))
	-> S.debounce(500)
	-> S.log
	// -> S.filter(v => mod(v, 2) == 0)
	-> S.collect(res => {
		switch res {
			| Ok(arr) => {
				Js.log(arr)
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