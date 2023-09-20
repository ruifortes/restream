open ReStream_Source

let fromArray = ReStream_Source.fromArray

let tap = fn => {
	let f = src => ReStream_Through.tap(src, fn)
	f
}

let log = ReStream_Through.log

let group = size => {
	let f = src => ReStream_Group.make(src, size)
	f
}

let map = mapper => {
	let f = src => ReStream_Transform_Map.makeSync(src, mapper)
	f
}

let asyncMap = mapper => {
	let f = src => ReStream_Transform_Map.makeAsync(src, mapper)
	f
}

let collect = cb => {
	let f = src => ReStream_Sink.collect(src, cb)
	f
}

let collectToPromise = ReStream_Sink.collectToPromise

let drain = onEnd => {
	let f = src => ReStream_Sink.drain(~onEnd, src)
	f
}


