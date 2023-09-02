open ReStream_Source

type sourceStatus<'a> = | Idle(readable<'a>) | Busy | Ended | Erroed(exn)

type combineMode = | Latest | Zip

let make2 = (~mode: combineMode = Latest, src1: readable<'a>, src2: readable<'b>) :readable<('a, 'b)> => {

	let starting = ref(true)
	let val1: ref<option<'a>> = ref(None)
	let val2: ref<option<'b>> = ref(None)
	let src1Status = ref(Idle(src1))
	let src2Status = ref(Idle(src2))

	let pendingCallback: ref<option<callback<('a, 'b)>>> = ref(None)

	let ended = () => {
		switch (mode, src1Status.contents, src2Status.contents) {
			| (Latest, Ended, Ended) => true
			| (Zip, Ended, _) => true
			| (Zip, _, Ended) => true
			| _ => false
		}
	}

	let erroed = () => {
		switch (mode, src1Status.contents, src2Status.contents) {
			| (_, Erroed(err), _) => Some(err)
			| (_, _, Erroed(err)) => Some(err)
			| _ => None
		}
	}

	let rec pullfromSources = () => {
		switch src1Status.contents {
			| Idle(src) => {
				src1Status := Busy
				src(Pull(payload => {
					switch payload {
						| Data(v)=> {
								src1Status := Idle(src)
								val1 := Some(v)
								maybeSend()
							}
						| End => {
								src1Status := Ended
								maybeEnd()
							}
						| Error(err) => {
								src1Status := Erroed(err)
								maybeEnd()
							}
					}
					
				}))

			}
			| _ => ()
		}

		switch src2Status.contents {
			| Idle(src) => {
				src2Status := Busy
				src(Pull(payload => {
					switch payload {
						| Data(v)=> {
								src2Status := Idle(src)
								val2 := Some(v)
								maybeSend()
							}
						| End => {
								src2Status := Ended
								maybeEnd()
							}
						| Error(err) => {
								src2Status := Erroed(err)
								maybeEnd()
							}
					}
					
				}))

			}
			| _ => ()
		}
		
	} and maybeSend = () => { 

		switch (pendingCallback.contents, val1.contents, val2.contents) {
			| (Some(cb), Some(v1), Some(v2)) => {
					pendingCallback := None
					switch mode {
						| Zip => {
							val1 := None
							val2 := None
						}
						| Latest => ()
					}
					cb(Data(v1,v2))

					switch (ended(), erroed()) {
						| (false, None) => pullfromSources()
						| _ => ()
					}

				}
			| _ => ()
		}

	} and maybeEnd = () => {
		switch (ended(), erroed(), pendingCallback.contents) {
				| (true, _, Some(cb)) => {
						pendingCallback := None
						cb(End)
					}
				| (_, Some(err), Some(cb)) => {
						cb(Error(err))
						pendingCallback := None
					}
				| _ => ()
			}	
	}


	(sig: ReStream_Source.signal<('a, 'b)>) => {

		switch sig {
			| Pull(cb) => {
					pendingCallback := Some(cb)
					if(starting.contents) {
						starting := false
						pullfromSources()
					}
				}
			| Abort => {
					src1(Abort)
					src2(Abort)
				}
			}
		}	

}


let make3 = (~mode = Latest, src1: readable<'a>, src2: readable<'b>, src3: readable<'c>) :readable<('a, 'b, 'c)> => {

	let starting = ref(true)
	let val1: ref<option<'a>> = ref(None)
	let val2: ref<option<'b>> = ref(None)
	let val3: ref<option<'c>> = ref(None)
	let src1Status = ref(Idle(src1))
	let src2Status = ref(Idle(src2))
	let src3Status = ref(Idle(src3))

	let pendingCallback: ref<option<callback<('a, 'b, 'c)>>> = ref(None)

	let ended = () => {
		switch (mode, src1Status.contents, src2Status.contents, src3Status.contents) {
			| (Latest, Ended, Ended, Ended) => true
			| (Zip, Ended, _, _) => true
			| (Zip, _, Ended, _) => true
			| (Zip, _, _, Ended) => true
			| _ => false
		}
	}

	let erroed = () => {
		switch (mode, src1Status.contents, src2Status.contents, src3Status.contents) {
			| (_, Erroed(err), _, _) => Some(err)
			| (_, _, Erroed(err), _) => Some(err)
			| (_, _, _, Erroed(err)) => Some(err)
			| _ => None
		}
	}

	let rec pullfromSources = () => {

		switch src1Status.contents {
			| Idle(src) => {
				src1Status := Busy
				src(Pull(payload => {
					switch payload {
						| Data(v)=> {
								src1Status := Idle(src)
								val1 := Some(v)
								maybeSend()
							}
						| End => {
								src1Status := Ended
								maybeEnd()
							}
						| Error(err) => {
								src1Status := Erroed(err)
								maybeEnd()
							}
					}
					
				}))

			}
			| _ => ()
		}

		switch src2Status.contents {
			| Idle(src) => {
				src2Status := Busy
				src(Pull(payload => {
					switch payload {
						| Data(v)=> {
								src2Status := Idle(src)
								val2 := Some(v)
								maybeSend()
							}
						| End => {
								src2Status := Ended
								maybeEnd()
							}
						| Error(err) => {
								src2Status := Erroed(err)
								maybeEnd()
							}
					}
					
				}))

			}
			| _ => ()
		}

		switch src3Status.contents {
			| Idle(src) => {
				src3Status := Busy
				src(Pull(payload => {
					switch payload {
						| Data(v)=> {
								src3Status := Idle(src)
								val3 := Some(v)
								maybeSend()
							}
						| End => {
								src3Status := Ended
								maybeEnd()
							}
						| Error(err) => {
								src3Status := Erroed(err)
								maybeEnd()
							}
					}
					
				}))

			}
			| _ => ()
		}
		
	} and maybeSend = () => {

		switch (pendingCallback.contents, val1.contents, val2.contents, val3.contents) {
			| (Some(cb), Some(v1), Some(v2), Some(v3)) => {
					pendingCallback := None
					switch mode {
						| Zip => {
							val1 := None
							val2 := None
							val3 := None
						}
						| Latest => ()
					}
					cb(Data(v1,v2, v3))

					switch (ended(), erroed()) {
						| (false, None) => pullfromSources()
						| _ => ()
					}
				}
			| _ => ()
		}

	} and maybeEnd = () => {
		switch (ended(), erroed(), pendingCallback.contents) {
				| (true, _, Some(cb)) => {
						pendingCallback := None
						cb(End)
					}
				| (_, Some(err), Some(cb)) => {
						cb(Error(err))
						pendingCallback := None
					}
				| _ => ()
			}	


	}

	(sig: ReStream_Source.signal<('a, 'b, 'c)>) => {

		switch sig {
			| Pull(cb) => {
					pendingCallback := Some(cb)
					if(starting.contents) {
						starting := false
						pullfromSources()
					}
				}
			| Abort => {
					src1(Abort)
					src2(Abort)
					src3(Abort)
				}
			}
		}

}


let make4 = (~mode = Latest, src1: readable<'a>, src2: readable<'b>, src3: readable<'c>, src4: readable<'d>) :readable<('a, 'b, 'c, 'd)> => {

	let srcA = make2(~mode, src1, src2)
	let srcB = make2(~mode, src3, src4)

	make2(~mode, srcA, srcB)
	-> ReStream_Transform.map((((a, b), (c, d))) => {
		(a, b, c, d)
	})

}


let make5 = (~mode = Latest, src1, src2, src3, src4, src5) :readable<('a, 'b, 'c, 'd, 'e)> => {

	let srcA = make2(~mode, src1, src2)
	let srcB = make3(~mode, src3, src4, src5)

	make2(~mode, srcA, srcB)
	-> ReStream_Transform.map((((a, b), (c, d, e))) => {
		(a, b, c, d, e)
	})

}


let make6 = (~mode = Latest, src1, src2, src3, src4, src5, src6) :readable<('a, 'b, 'c, 'd, 'e, 'f)> => {

	let srcA = make3(~mode, src1, src2, src3)
	let srcB = make3(~mode, src4, src5, src6)

	make2(~mode, srcA, srcB)
	-> ReStream_Transform.map((((a, b, c), (d, e, f))) => {
		(a, b, c, d, e, f)
	})

}