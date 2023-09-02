module S = ReStream	

let refDone1 = ref(false)

let src1 = S.fromArray([1, 2, 3, 4, 5])
-> S.asyncMap((v, cb) => {
	v -> Test_Utils.rndDelay(~min=50, ~max=100, cb)
})


src1
-> ReStream_Through.log
-> ReStream_Through.tap(v => {
		// refVal1 := Some(v)
		// send()
		Js.log("x")
	})
// -> throughNext2
-> ReStream_Sink.drain(~onEnd = _ => refDone1 := true) 