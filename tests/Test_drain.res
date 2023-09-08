open Test

module S = ReStream

let arr1 = Belt.Array.range(1, 10)
let arr2 = arr1 -> Belt.Array.map(v => "#" ++ Js.Int.toString(v))

testAsync("drain, sync", (done) => {

	let testArr = []

	S.fromArray(arr1)
	-> S.map(v => {
			"#" ++ Js.Int.toString(v)
		})
	// -> S.log
	-> S.tap(v => testArr -> Js.Array2.push(v) -> ignore)
	-> S.drain(~onEnd = ret => {
		switch ret {
			| Ok(_) => {
					Assert.arrayDeepEqual(~message="results match", testArr, arr2)
					done()
				}
			| Error(_) => fail()
		}
	})


})

testAsync("drain, async", (done) => {

	let testArr = []

	S.fromArray(arr1)
	-> S.asyncMap((v, cb) => {
			("#" ++ Js.Int.toString(v)) -> Test_Utils.rndDelay(~min=50, ~max=50, cb)
		})
	// -> S.log
	-> S.tap(v => testArr -> Js.Array2.push(v) -> ignore)
	-> S.drain(~onEnd = ret => {
		switch ret {
			| Ok(_) => {
					Assert.arrayDeepEqual(~message="results match", testArr, arr2)
					done()
				}
			| Error(_) => fail()
		}
	})


})


testAsync("abortableDrain", (done) => {

	let testArr = []

	let abort = S.fromArray(arr1)
	-> S.asyncMap((v, cb) => {
			("#" ++ Js.Int.toString(v)) -> Test_Utils.rndDelay(~min=50, ~max=50, cb)
		})
	// -> S.log
	-> S.tap(v => testArr -> Js.Array2.push(v) -> ignore)
	-> S.abortableDrain(~onEnd = ret => {
		switch ret {
			| Ok(_) => {
					Assert.arrayDeepEqual(~message="results match", testArr, ["#1", "#2", "#3", "#4"])
					done()
				}
			| Error(_) => fail()
		}
	})
 

	Js.Global.setTimeout(() => {
		abort()
	}, 200) -> ignore

})