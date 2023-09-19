open Test

module S = ReStream

let testData_A = [
	(1, 400),
	(2, 200),
	(3, 100),
	(4, 10),
	(5, 1000),
	(6, 50),
	(7, 50)
]

let delays = [500, 1000, 300, 200, 1000, 50, 100]

testAsync("paramap, async source, keepOrder=false, parallel = 10", ~timeout=10000, (done) => {

	let i = ref(-1)
	let fail1 = ref(false)

	Test_Utils.createAsyncTestSource(testData_A)
	-> ReStream_Utils.checkStep(() => fail1 := true)
	-> S.paraMap(~keepOrder = false, (val, cb) => {
			let newValue = "#" ++ Int.toString(val)
			switch delays[ReStream_Utils.incrementRef(i)] {
				| Some(delay) => setTimeout(() => cb(newValue), delay) -> ignore
				| None => ()
			}
	}, 10)
	// -> S.log
	-> S.collect(res => {
		switch res {
			| Ok(arr) => {
					let expected = [1, 4, 3, 2, 6, 7, 5] -> Belt.Array.map(n => "#" ++ Int.toString(n))
					Assert.boolEqual(~message="must not call Pull before receiving payload", fail1.contents, false)
					Assert.arrayDeepEqual(~message="results match", arr, expected)
					done()
				}
			| Error(_) => {
					fail()
				}
			}
		})

})


testAsync("paramap, async source, keepOrder=false, parallel = 1", ~timeout=10000, (done) => {

	let i = ref(-1)
	let fail1 = ref(false)

	Test_Utils.createAsyncTestSource(testData_A)
	-> ReStream_Utils.checkStep(() => fail1 := true)
	-> S.paraMap(~keepOrder = false, (val, cb) => {
			let newValue = "#" ++ Int.toString(val)
			switch delays[ReStream_Utils.incrementRef(i)] {
				| Some(delay) => setTimeout(() => cb(newValue), delay) -> ignore
				| None => ()
			}
	}, 1)
	// -> S.log
	-> S.collect(res => {
		switch res {
			| Ok(arr) => {
					let expected = [1, 2, 3, 4, 5, 6, 7] -> Belt.Array.map(n => "#" ++ Int.toString(n))
					Assert.boolEqual(~message="must not call Pull before receiving payload", fail1.contents, false)
					Assert.arrayDeepEqual(~message="results match", arr, expected)
					done()
				}
			| Error(_) => {
					fail()
				}
			}
		})

})


testAsync("paramap, async source, keepOrder=true, parallel = 10", ~timeout=10000, (done) => {

	let i = ref(-1)
	let fail1 = ref(false)

	Test_Utils.createAsyncTestSource(testData_A)
	-> ReStream_Utils.checkStep(() => fail1 := true)
	-> S.paraMap(~keepOrder = true, (val, cb) => {
			let newValue = "#" ++ Int.toString(val)
			switch delays[ReStream_Utils.incrementRef(i)] {
				| Some(delay) => setTimeout(() => cb(newValue), delay) -> ignore
				| None => ()
			}
	}, 10)
	// -> S.log
	-> S.collect(res => {
		switch res {
			| Ok(arr) => {
					let expected = [1, 2, 3, 4, 5, 6, 7] -> Belt.Array.map(n => "#" ++ Int.toString(n))
					Assert.boolEqual(~message="must not call Pull before receiving payload", fail1.contents, false)
					Assert.arrayDeepEqual(~message="results match", arr, expected)
					done()
				}
			| Error(_) => {
					fail()
				}
			}
		})

})


testAsync("paramap, sync source, keepOrder=false, parallel = 10", (done) => {

	let i = ref(-1)
	let fail1 = ref(false)

	S.fromArray([1, 2, 3, 4, 5, 6, 7])
	-> ReStream_Utils.checkStep(() => fail1 := true)
	-> S.paraMap(~keepOrder = false, (val, cb) => {
			let newValue = "#" ++ Int.toString(val)
			switch delays[ReStream_Utils.incrementRef(i)] {
				| Some(delay) => setTimeout(() => cb(newValue), delay) -> ignore
				| None => ()
			}
	}, 10)
	// -> S.log
	-> S.collect(res => {
		switch res {
			| Ok(arr) => {
					let expected = [6, 7, 4, 3, 1, 2, 5] -> Belt.Array.map(n => "#" ++ Int.toString(n))
					Assert.boolEqual(~message="must not call Pull before receiving payload", fail1.contents, false)
					Assert.arrayDeepEqual(~message="results match", arr, expected)
					done()
				}
			| Error(_) => {
					fail()
				}
			}
		})

})


testAsync("paramap, sync source, keepOrder=true, parallel = 10", (done) => {

	let i = ref(-1)
	let fail1 = ref(false)

	S.fromArray([1, 2, 3, 4, 5, 6, 7])
	-> ReStream_Utils.checkStep(() => fail1 := true)
	-> S.paraMap(~keepOrder = true, (val, cb) => {
			let newValue = "#" ++ Int.toString(val)
			switch delays[ReStream_Utils.incrementRef(i)] {
				| Some(delay) => setTimeout(() => cb(newValue), delay) -> ignore
				| None => ()
			}
	}, 10)
	-> S.collect(res => {
		switch res {
			| Ok(arr) => {
					let expected = [1, 2, 3, 4, 5, 6, 7] -> Belt.Array.map(n => "#" ++ Int.toString(n))
					Assert.boolEqual(~message="must not call Pull before receiving payload", fail1.contents, false)
					Assert.arrayDeepEqual(~message="results match", arr, expected)
					done()
				}
			| Error(_) => {
					fail()
				}
			}
		})

})


testAsync("paramap, sync source, keepOrder=true, parallel = 1", (done) => {

	let i = ref(-1)
	let fail1 = ref(false)

	S.fromArray([1, 2, 3, 4, 5, 6, 7])
	-> ReStream_Utils.checkStep(() => fail1 := true)
	-> S.paraMap(~keepOrder = true, (val, cb) => {
			let newValue = "#" ++ Int.toString(val)
			switch delays[ReStream_Utils.incrementRef(i)] {
				| Some(delay) => setTimeout(() => cb(newValue), delay) -> ignore
				| None => ()
			}
	}, 1)
	-> S.collect(res => {
		switch res {
			| Ok(arr) => {
					let expected = [1, 2, 3, 4, 5, 6, 7] -> Belt.Array.map(n => "#" ++ Int.toString(n))
					Assert.boolEqual(~message="must not call Pull before receiving payload", fail1.contents, false)
					Assert.arrayDeepEqual(~message="results match", arr, expected)
					done()
				}
			| Error(_) => {
					fail()
				}
			}
		})

})

testAsync("paramap, sync source, immediate response, keepOrder=false", (done) => {

	let fail1 = ref(false)

	S.fromArray([1, 2, 3, 4, 5, 6, 7])
	-> ReStream_Utils.checkStep(() => fail1 := true)
	-> S.paraMap(~keepOrder = true, (val, cb) => {
			let newValue = "#" ++ Int.toString(val)
			cb(newValue)
	}, 10)
	-> S.collect(res => {
		switch res {
			| Ok(arr) => {
					let expected = [1, 2, 3, 4, 5, 6, 7] -> Belt.Array.map(n => "#" ++ Int.toString(n))
					Assert.boolEqual(~message="must not call Pull before receiving payload", fail1.contents, false)
					Assert.arrayDeepEqual(~message="results match", arr, expected)
					done()
				}
			| Error(_) => {
					fail()
				}
			}
		})

})


