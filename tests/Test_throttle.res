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
