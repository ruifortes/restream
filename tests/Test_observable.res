open Test

module S = ReStream

testAsync("observable", (done) => {

	let arr1 = Belt.Array.range(1, 6)
	let arr2 = arr1 -> Array.map(v => "#" ++ Int.toString(v))

	let results = Belt.MutableMap.Int.make()

	let fail1 = ref(false)

	let makeObserverCallback = id => {

			let arr = [] 
			results -> Belt.MutableMap.Int.set(id, arr)

			(pl: ReStream_Source.payload<'a>) => {

				switch pl {
					| Data(val) => {
						arr -> Array.push(val) -> ignore
					}
					| _ => ()
				}
				
			}

	}

	let (observable, observe) = S.observable()

	let rem1 = observe(makeObserverCallback(1))

	setTimeout(() => {
		let rem2 = observe(makeObserverCallback(2))
	}, 120) -> ignore

	setTimeout(() => {
		rem1()
	}, 220) -> ignore


	S.fromArray(arr1)
	-> ReStream_Utils.checkStep(() => fail1 := true)
	-> S.asyncMap((v, cb) => {
			("#" ++ Int.toString(v)) -> Test_Utils.rndDelay(~min=50, ~max=50, cb)
		})
	-> observable
	// -> S.log
	-> S.collect(res => {
		switch res {
			| Ok(arr) => {
					Assert.boolEqual(~message="must not call Pull before receiving payload", fail1.contents, false)
					Assert.arrayDeepEqual(~message="results match", arr, arr2)

					{
						open Belt.MutableMap.Int
						switch (results -> get(1), results -> get(2)) {
							| (Some(v1), Some(v2)) => {
								Assert.arrayDeepEqual(~message="first observer results match", v1, ["#1", "#2", "#3"])
								Assert.arrayDeepEqual(~message="second observer results match", v2, ["#3", "#4", "#5", "#6"])
							}
							| (_, _) => fail()
						}
					}

					done()
				}
			| Error(_) => fail()
			}
		})

})