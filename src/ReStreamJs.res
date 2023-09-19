open ReStream_Source

let fromArray = ReStream_Source.fromArray

let log = ReStream_Through.log

let group = (size, src) => ReStream_Group.make(src, size)

let map = (mapper, src) => ReStream_Transform_Map.makeSync(src, mapper)

let collect = (cb, src) => src => ReStream_Sink.collect(src, cb)

let drain = ReStream_Sink.drain



