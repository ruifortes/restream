open Test

module S = ReStream

testAsync("flatMap", (done) => {


	S.fromArray([1, 2, 3])
	-> S.flatMap(v => {
			Belt.Array.makeBy(v, _ => v)
		})
	-> S.log
	-> S.collect(res => {
		switch res {
			| Ok(arr) => {
					Assert.arrayDeepEqual(~message="results match", arr, [1,2,2,3,3,3])
					done()
				}
			| Error(_) => fail()
			}
		})

})

testAsync("asyncFlatMap", (done) => {


	S.fromArray([1, 2, 3])
	-> S.asyncFlatMap((v, cb) => {
			Belt.Array.makeBy(v, _ => v) -> Test_Utils.rndDelay(~min=10, ~max=50, cb)
		})
	-> S.log
	-> S.collect(res => {
		switch res {
			| Ok(arr) => {
					Assert.arrayDeepEqual(~message="results match", arr, [1,2,2,3,3,3])
					done()
				}
			| Error(_) => fail()
			}
		})

})