open Test
module S = ReStream

testAsync("asyncMap", (done) => {

	S.fromArray([1, 2, 3, 4])
	-> S.asyncMap((v, cb) => {
			let newValue = "#" ++ Js.Int.toString(v)
			newValue -> Test_Utils.rndDelay(~min=10, ~max=100, cb)
		})
	-> S.collect(res => {
		switch res {
			| Ok(arr) => {
					Assert.arrayDeepEqual(~message="results match", arr, ["#1", "#2","#3","#4"])
					done()
				}
			| Error(err) => {
					fail()
				}
			}		

	})

})