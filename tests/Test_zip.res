open Test

module S = ReStream

let createSources = () => {

	let src1 = S.fromArray([1, 2, 3, 4, 5])
		-> S.asyncMap((v, cb) => {
			v -> Test_Utils.rndDelay(~min=50, ~max=100, cb)
		})

	let src2 = S.fromArray(["A", "B", "C", "D", "E"])
		-> S.asyncMap((v, cb) => {
				v -> Test_Utils.rndDelay(~min=150, ~max=200, cb)
			})

	let src3 = S.fromArray([10, 20, 30, 40, 50])
		-> S.asyncMap((v, cb) => {
			v -> Test_Utils.rndDelay(~min=50, ~max=100, cb)
		})

	let src4 = S.fromArray(["AA", "BB", "CC", "DD", "EE"])
		-> S.asyncMap((v, cb) => {
				v -> Test_Utils.rndDelay(~min=150, ~max=200, cb)
			})

	let src5 = S.fromArray([true, false, false, true, true])
		-> S.asyncMap((v, cb) => {
				v -> Test_Utils.rndDelay(~min=150, ~max=200, cb)
			})

	let src6 = S.fromArray([100, 200, 300, 400, 500])
		-> S.asyncMap((v, cb) => {
			v -> Test_Utils.rndDelay(~min=50, ~max=100, cb)
		})

	(src1, src2, src3, src4, src5, src6)

}



testAsync("zip2", (done) => {

	let src1 = S.fromArray([1, 2, 3, 4, 5])
		-> S.asyncMap((v, cb) => {
			v -> Test_Utils.rndDelay(~min=50, ~max=100, cb)
		})

	let src2 = S.fromArray(["A", "B", "C", "D", "E"])
		-> S.asyncMap((v, cb) => {
				v -> Test_Utils.rndDelay(~min=150, ~max=200, cb)
			})


	S.zip2(src1, src2)
	-> S.log
	-> S.collect(res => {
		switch res {
			| Ok(_) => {
					done()
				}
			| Error(_) => fail()
			}
		})

})


testAsync("zip3", (done) => {

	let (src1, src2, src3, _, _, _) = createSources()

	S.zip3(src1, src2, src3)
	-> S.log
	-> S.collect(res => {
		switch res {
			| Ok(_) => {
					done()
				}
			| Error(_) => fail()
			}
		})

})


testAsync("zip4", (done) => {

	let (src1, src2, src3, src4, _, _) = createSources()

	S.zip4(src1, src2, src3, src4)
	// -> S.log
	-> S.collect(res => {
		switch res {
			| Ok(_) => {
					done()
				}
			| Error(_) => fail()
			}
		})

})


testAsync("zip5", (done) => {

	let (src1, src2, src3, src4, src5, _) = createSources()

	S.zip5(src1, src2, src3, src4, src5)
	// -> S.log
	-> S.collect(res => {
		switch res {
			| Ok(_) => {
					done()
				}
			| Error(_) => fail()
			}
		})

})

testAsync("zip6", (done) => {

	let (src1, src2, src3, src4, src5, src6) = createSources()

	S.zip6(src1, src2, src3, src4, src5, src6)
	// -> S.log
	-> S.collect(res => {
		switch res {
			| Ok(_) => {
					// let expected = [1, 2, 3, 4, 5, 6, 7] -> Belt.Array.map(n => "#" ++ Int.toString(n))
					// Assert.boolEqual(~message="must not call Pull before receiving payload", fail1.contents, false)
					// Assert.arrayDeepEqual(~message="results match", arr, expected)
					done()
				}
			| Error(_) => fail()
				
			}
		})

})