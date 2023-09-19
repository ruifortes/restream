open Test

module S = ReStream

let testValues = ["A", "B", "C", "D"]
let testDelays = [300, 200, 100, 10]
let testData = Belt.Array.zip(testValues, testDelays)

let _act = (actionable: S.actionable<'a>, steps: array<('a, int)>) => {

	let rec step = () => {
		switch steps -> Array.shift {
			| Some(v, d) => {
					let _ = setTimeout(() => {
						actionable(Push(v))
						step()
					}, d)
				}
			| None => actionable(Close)
		}
	}

	step()
}

testAsync("actionable", (done) => {

	let (source, actionable) = S.actionable()


	source
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

	_act(actionable, testData)

})