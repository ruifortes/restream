open Test
module S = ReStream

testAsync("map", (done) => {

	S.fromArray([1, 2, 3, 4])
	-> S.map((v) => "#" ++ Js.Int.toString(v) )
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

