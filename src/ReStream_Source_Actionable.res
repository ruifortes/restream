type action<'a> = 
	| Push('a)
	| Close

type actionable<'a> = action<'a> => unit


let make = () :(ReStream_Source.readable<'a>, actionable<'a>) => {

	let dataQueue :Belt.MutableQueue.t<'a> = Belt.MutableQueue.make()
	let pendingCallbacks :Belt.MutableQueue.t<ReStream_Source.callback<'a>> = Belt.MutableQueue.make()
	let closed = ref(false)

	let actionableSource: actionable<'a> = (act) => {
		switch act {
			| Push(val) => {
					switch pendingCallbacks -> Belt.MutableQueue.pop {
						| Some(cb) => cb(Data(val))
						| None => dataQueue -> Belt.MutableQueue.add(val)
					}
				}
			| Close => {
					closed := true
					pendingCallbacks -> Belt.MutableQueue.forEach(cb => cb(End))
				}  
			}
	}
 
	let readable :ReStream_Source.readable<'a> = (sig) => {
		switch sig {
			| Pull(cb) => {
					switch dataQueue -> Belt.MutableQueue.pop {
							| Some(val) => {
									cb(Data(val))
								}
							| None => {
								if(closed.contents) {
									cb(End)
								} else {
									pendingCallbacks -> Belt.MutableQueue.add(cb)
								}
							}
						}
				}
			|	Abort => Js.log("TODO")
		}
	}

	
	(readable, actionableSource)
		
}
