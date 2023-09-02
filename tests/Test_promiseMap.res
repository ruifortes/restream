open Test
module S = ReStream


testAsync("promiseMap", (done) => {

	S.fromArray([1, 2, 3, 4])
	-> S.promiseMap(v => {

			let newValue = "#" ++ Js.Int.toString(v)

			Js.Promise.make((~resolve, ~reject) => {
				newValue -> Test_Utils.rndDelay(~min=10, ~max=100, v => resolve(. v))
			})

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


testAsync("promiseMap should handle errors", (done) => {

	let i = ref(0)

	S.fromArray([1, 2, 3, 4, 5, 6])
	-> S.promiseMap(v => {

			let newValue = "#" ++ Js.Int.toString(v)

			Js.Promise.make((~resolve, ~reject) => {
				if(ReStream_Utils.incrementRef(i) == 5) {
					reject(. Failure("some error"))
				} else {
					newValue -> Test_Utils.rndDelay(~min=10, ~max=100, v => resolve(. v))
				}
			})

		})
	-> S.collect(res => {
		switch res {
			| Ok(arr) => {
					fail()
				}
			| Error(err) => {
					done()
				}
			}		

	})

})
