open ReStream_Source


let make = (src: readable<'a>, ~keepOrder = true, fn: ('a, 'b => unit) => unit, size :int) :readable<'b> => {

	let count = ref(0)
	let sourceEnded = ref(false)
	let pullingSource = ref(false)

	let payloadPlaceholders: Belt.MutableMap.Int.t<ref<option<payload<'b>>>> = Belt.MutableMap.Int.make()
	let pendingCallback: ref<option<callback<'b>>> = ref(None)

	let _getNextPayload = (placeholders, keepOrder) => { //TODO optimize this

		let skip = ref(false)
		let nextPayload = ref(None)

		switch keepOrder {
			| true => {
				switch placeholders -> Belt.MutableMap.Int.minKey {
					| Some(k) => switch placeholders -> Belt.MutableMap.Int.get(k) {
						| Some(v) => switch v.contents {
							| Some(payload) => {
								placeholders -> Belt.MutableMap.Int.remove(k) 
								nextPayload := Some(payload)
							}
							| None => ()
						}
						| None => ()
					}
					| None => ()
				}
			}
			| false => {
				placeholders -> Belt.MutableMap.Int.forEach((k, v) => {
					if(!skip.contents) {
						switch v.contents {
							| Some(payload) => {
								skip := true
								
								switch payload {
									| Data(val) => {
											placeholders -> Belt.MutableMap.Int.remove(k)
											nextPayload := Some(payload)
										}
									| _ => {
										if(placeholders -> Belt.MutableMap.Int.size == 1) {
											placeholders -> Belt.MutableMap.Int.remove(k)
											nextPayload := Some(payload)
										}
									}

								}

							}
							| None => ()
						}
					}
				})
			}
		}

		nextPayload.contents

	}


	let rec maybeSendResponse = () => {

		switch (_getNextPayload(payloadPlaceholders, keepOrder), pendingCallback.contents) {
			| (Some(payload), Some(cb)) => {
					switch pendingCallback.contents {
						| Some(cb) => cb(payload)
						| None => ()
					}
			}
			| _ => ()
		}

	} and pullNext = () => {

		if (!pullingSource.contents && !sourceEnded.contents && payloadPlaceholders -> Belt.MutableMap.Int.size < size) {
			pullingSource := true

			let k = count -> ReStream_Utils.incrementRef

			let placeholder = ref(None)

			payloadPlaceholders -> Belt.MutableMap.Int.set(k, placeholder)

			src(Pull((payload) => {
				pullingSource := false
				switch payload {
					| Data(val) => {
						fn(val, (retVal: 'b) => {
							placeholder := Some(Data(retVal))
							maybeSendResponse()
						})
					}
					| End => {
							placeholder := Some(End)
							sourceEnded := true
							maybeSendResponse()
						}
					| Error(err) => {
							placeholder := Some(Error(err))
							sourceEnded := true
							maybeSendResponse()
					}
				}

				pullNext()
				
			}))

		}

	}

	(sig :signal<'b>) => {
		switch sig {
			| Pull(cb) => {
					pendingCallback := Some(cb)
					pullNext()
					maybeSendResponse()
				}
			| Abort => {
					src(Abort)
				}
			}

	}

}
