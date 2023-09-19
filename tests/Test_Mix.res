open Test

module S = ReStream

let testSourceData1 = ["A", "B", "C", "D", "E"]

let testResultData1 = testSourceData1
	-> Belt.Array.map(s => {
			Belt.Array.range(1, 4) -> Belt.Array.map(v => "#" ++ s ++ Int.toString(v))
		})
	-> Belt.Array.concatMany


testAsync("mix, async source, parallel = 10", ~timeout=10000, (done) => {

	let fail1 = ref(false)

	S.fromArray(testSourceData1)
	-> ReStream_Utils.checkStep(() => fail1 := true)
	-> S.asyncMap((s, cb) => {
			let source = Belt.Array.range(1, 4)
			-> S.fromArray
			-> S.asyncMap((v, cb) => {
					let newValue = "#" ++ s ++ Int.toString(v)
					newValue -> Test_Utils.rndDelay(~min=100, ~max=100, cb)
				})

			Test_Utils.rndDelay(source, cb)

		})
	-> S.mix(~parallel = 10)
	// -> S.log
	-> S.collect(res => {
		switch res {
			| Ok(arr) => {
					Assert.boolEqual(~message="must not call Pull before receiving payload", fail1.contents, false)
					Assert.arraySameItems(~message="result array has same items", arr, testResultData1)
					done()
				}
			| Error(_) => fail()
			}
		})

})


testAsync("mix, sync source, parallel = 10", ~timeout=10000, (done) => {

	let fail1 = ref(false)

	S.fromArray(testSourceData1)
	-> ReStream_Utils.checkStep(() => fail1 := true)
	-> S.map(s => {
			Belt.Array.range(1, 4)
			-> S.fromArray
			-> S.map(v => {
					"#" ++ s ++ Int.toString(v)
				})
		})
	-> S.mix(~parallel = 10)
	// -> S.log
	-> S.collect(res => {
		switch res {
			| Ok(arr) => {
					Assert.boolEqual(~message="must not call Pull before receiving payload", fail1.contents, false)
					Assert.arraySameItems(~message="result array has same items", arr, testResultData1)
					done()
				}
			| Error(_) => fail()
			}
		})

})

testAsync("mix, parallel = 1", ~timeout=10000, (done) => {

	let fail1 = ref(false)

	S.fromArray(testSourceData1)
	-> ReStream_Utils.checkStep(() => fail1 := true)
	-> S.asyncMap((s, cb) => {
			let source = Belt.Array.range(1, 4)
			-> S.fromArray
			-> S.asyncMap((v, cb) => {
					let newValue = "#" ++ s ++ Int.toString(v)
					newValue -> Test_Utils.rndDelay(~min=100, ~max=100, cb)
				})

			Test_Utils.rndDelay(source, cb)

		})
	-> S.mix(~parallel = 1)
	// -> S.log
	-> S.collect(res => {
		switch res {
			| Ok(arr) => {
					Assert.boolEqual(~message="must not call Pull before receiving payload", fail1.contents, false)
					Assert.arrayDeepEqual(~message="results should be ordered", arr, testResultData1)
					done()
				}
			| Error(_) => fail()
			}
		})

})

testAsync("flatten (mix with parallel = 1), sync sources", (done) => {

	let fail1 = ref(false)

	S.fromArray(["A", "B", "C"])
	-> S.map(s => 
			S.fromArray([1, 2, 3])
			-> S.map(n => "#" ++ s ++ Int.toString(n))
		)
	-> ReStream_Utils.checkStep(() => fail1 := true)
	-> S.flatten
	-> S.collect(res => {
		switch res {
			| Ok(arr) => {
					Assert.boolEqual(~message="must not call Pull before receiving payload", fail1.contents, false)
					Assert.arrayDeepEqual(~message="results match", arr, ["#A1", "#A2", "#A3", "#B1", "#B2", "#B3","#C1", "#C2", "#C3",])
					done()
				}
			| Error(_) => fail()
			}
		})

})