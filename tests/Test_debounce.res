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

	Test_Utils.createAsyncTestSource(testData_A)
	-> S.debounce(500)
	-> S.log
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

