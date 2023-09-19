// open Test

// module S = ReStream

// // testAsync("next", (done) => {

// 	let (throughNext, next) = ReStream_Sink.step()

// 	S.fromArray([1, 2, 3, 4, 5, 6])
// 	-> S.asyncMap((v, cb) => {
// 			v -> Test_Utils.rndDelay(~min=100, ~max=200, cb)
// 		})
// 	-> throughNext
// 	-> S.log
// 	-> S.collect(res => {

// 		switch res {
// 			| Ok(arr) => {
// 				Js.log(arr)
// 					// Assert.arrayDeepEqual(~message="results match", arr, ["A", "B", "C", "D"])
// 					// done()
// 				}
// 			| Error(err) => {
// 				Js.log(err)
// 					// fail()
// 				}
// 			}		
	
// 	})

// 	// let _ = setTimeout(next, 1000)
// 	// let _ = setTimeout(next, 3000)
// 	// let _ = setTimeout(next, 4000)

// 	let rec getNext = () => {
// 		if (next()) {
// 			Js.log("XXXXXXX")
// 				() -> Test_Utils.rndDelay(~min=50, ~max=100, getNext)
// 		}
// 		// setTimeout(getNext, 4000)
// 	}

// 	() -> Test_Utils.rndDelay(~min=50, ~max=100, getNext)

// // })