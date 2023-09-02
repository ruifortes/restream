open Test
module Promise = Js.Promise
module S = ReStream

let testValues = ["A", "B", "C", "D"]
let testDelays = [300, 200, 100, 10]
let testData = Belt.Array.zip(testValues, testDelays)

test("fromArray", () => {
	let initialArray = [1, 2, 3, 4, 5]

	S.fromArray([1, 2, 3, 4, 5])
	-> S.collect(res => {

		switch res {
			| Ok(arr) => {
					Assert.arrayDeepEqual(~message="results match", arr, [1, 2, 3, 4, 5])
				}
			| Error(err) => {
					fail()
				}
			}		
	
	})

})


testAsync("fromIterable (sync)", (done) => {

	let iterable = ReStream_Source_FromIterable._castArray([1, 2, 3, 4, 5]) 

	S.fromIterable(iterable)
	-> S.collect(res => {

		switch res {
			| Ok(arr) => {
					Assert.arrayDeepEqual(~message="results match", arr, [1, 2, 3, 4, 5])
					done()
				}
			| Error(err) => {
					fail()
				}
			}
	
	})

})


testAsync("fromIterable (async)", (done) => {

	let iterable = Test_Utils.asyncIteratorFromArray([1, 2, 3, 4, 5])

	S.fromIterable(iterable)
	-> S.collect(res => {

		switch res {
			| Ok(arr) => {
					Assert.arrayDeepEqual(~message="results match", arr, [1, 2, 3, 4, 5])
					done()
				}
			| Error(err) => {
					fail()
				}
			}
	
	})

})


testAsync("toWebStreamReadable", (done) => {

	Test_Utils.createAsyncTestSource(testData)
	-> S.toWebStreamReadable
	-> Test_Utils.testReadableWebStream
	-> Promise.then_(pass => {
			if(pass) {
				done()
			} else {
				fail()
			}
			Promise.resolve()
		}, _)
	-> ignore

})


testAsync("fromWebStreamReadable", (done) => {

	let readableWebStream = Test_Utils.createAsyncTestSource(testData) -> S.toWebStreamReadable

	S.fromWebStreamReadable(readableWebStream)
	-> S.collect(res => {

		switch res {
			| Ok(arr) => {
					Assert.arrayDeepEqual(~message="results match", arr, ["A", "B", "C", "D"])
					done()
				}
			| Error(err) => {
					fail()
				}
			}
	
	})

})

