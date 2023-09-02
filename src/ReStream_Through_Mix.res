open ReStream_Utils

type t<'a> = ReStream_Source.readable<'a>
type payload<'a> = ReStream_Source.payload<'a>
type callback<'a> = ReStream_Source.callback<'a>

type streamId = int
type stream<'a> = | Pending | Active(t<'a>) | Waiting(t<'a>)


let make = (~parallel = 10, source :t<t<'a>>) :t<'a> => {

	let streamCount: ref<streamId> = ref(0)
	let noMoreStreams = ref(false)
	let ended = ref(false)

	let streams: Belt.MutableMap.Int.t<stream<'a>> = Belt.MutableMap.Int.make()
	
	let values: Belt.MutableQueue.t<'a> = Belt.MutableQueue.make()
	let pendingCallback: ref<option<callback<'a>>> = ref(None)

	let rec getNextStream = () => {

		if(streams -> Belt.MutableMap.Int.size < parallel && noMoreStreams.contents == false) {

			let streamId = streamCount -> incrementRef

			let cb = (payload: payload<t<'a>>) :unit => {
				switch payload {
					| Data(s: t<'a>) => {
							streams -> Belt.MutableMap.Int.set(streamId, Active(s))
							pullFromStreams()
							getNextStream()
						}
					| End  => {
							noMoreStreams := true
							streams -> Belt.MutableMap.Int.remove(streamId)
						}
					| Error(err) => {
							noMoreStreams := true
							streams -> Belt.MutableMap.Int.remove(streamId)
					}
				}
			}

			streams -> Belt.MutableMap.Int.set(streamId, Pending)
			source(Pull(cb))
			
		}

	} and pullFromStreams = () => {

		streams -> Belt.MutableMap.Int.forEach((streamId, stream) => {

			switch stream {
				| Active(readable) => {

						streams -> Belt.MutableMap.Int.set(streamId, Waiting(readable))

						let cb = (payload: payload<'a>) => {

							switch streams -> Belt.MutableMap.Int.get(streamId) {
									| Some(Waiting(readable)) => streams -> Belt.MutableMap.Int.set(streamId, Active(readable))
									| _ => ()
								}

							switch payload {
								| Data(val: 'a) => {
										values -> Belt.MutableQueue.add(val)
										pullFromStreams()
										sendResponses()
									}
								| _ => streams -> Belt.MutableMap.Int.remove(streamId)
							}
						}

						readable(Pull(cb))
					} 
				| _ => ()
			}

		})

	} and sendResponses = () => {

		if(!ended.contents) {
			switch pendingCallback.contents {
				| Some(cb) => {
					switch values -> Belt.MutableQueue.pop {
						| Some(val) => {
							pendingCallback := None
							cb(Data(val))
						}
						| None => {
							if(streams -> Belt.MutableMap.Int.isEmpty) {
								ended := true
								cb(End)
							}
						}
					}
				}
				| None => ()
			}
		}

	}

	(sig :ReStream_Source.signal<'a>) => {
		if(!ended.contents) {

			switch sig {
				| Pull(cb) => {
						pendingCallback := Some(cb)
						getNextStream()
						sendResponses()
					}
				| Abort => {
						()
					}
				}

		}

	}

}

