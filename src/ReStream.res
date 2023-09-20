open ReStream_Source

// type readable<'a> = ReStream_Source.readable<'a>
// type signal<'a> = ReStream_Source.signal<'a>
// type payload<'a> = ReStream_Source.payload<'a>
// type callback<'a> = ReStream_Source.callback<'a>
type actionable<'a> = ReStream_Source_Actionable.actionable<'a>
type action<'a> = ReStream_Source_Actionable.action<'a>

let actionable = ReStream_Source_Actionable.make

let observable = ReStream_Observable.make

let fromArray = ReStream_Source.fromArray

let fromIterable = ReStream_Source_FromIterable.fromIterable
let fromWebStreamReadable = ReStream_WebStream.fromWebStreamReadable
let toWebStreamReadable = ReStream_WebStream.toWebStreamReadable

let abortable = ReStream_Through.abortable

let log = ReStream_Through.log
let tap = ReStream_Through.tap
let take = ReStream_Through.take
// let through = ReStream_Through.through
let debounce = ReStream_Debounce.make
let throttle = ReStream_Throttle.make
let timeout = ReStream_Through.timeout


let map = ReStream_Transform_Map.makeSync
let asyncMap = ReStream_Transform_Map.makeAsync
let promiseMap = ReStream_Transform_Map.makeAsyncPromised

let flatMap = ReStream_FlatMap.makeSync
let asyncFlatMap = ReStream_FlatMap.makeAsync

let paraMap = ReStream_Through_ParaMap.make

let filter = ReStream_Filter.makeSync
let asyncFilter = ReStream_Filter.makeAsync

let filterMap = ReStream_Filter.makeSyncFilterMap
let asyncFilterMap = ReStream_Filter.makeAsyncFilterMap

let group = ReStream_Group.make
let buffer = ReStream_Through_Buffer.make

let mix = ReStream_Through_Mix.make
let flatten = (source :t<t<'a>>) => source -> ReStream_Through_Mix.make(~parallel = 1)

let combineLatest2 = ReStream_Through_Combine.make2
let combineLatest3 = ReStream_Through_Combine.make3
let combineLatest4 = ReStream_Through_Combine.make4
let combineLatest5 = ReStream_Through_Combine.make5
let combineLatest6 = ReStream_Through_Combine.make6

// let zip2 = ReStream_Through_Combine.make2(~mode = Zip)
let zip2 = (src1, src2) => ReStream_Through_Combine.make2(~mode = Zip, src1, src2)
let zip3 = (src1, src2, src3) => ReStream_Through_Combine.make3(~mode = Zip, src1, src2, src3)
let zip4 = (src1, src2, src3, src4) => ReStream_Through_Combine.make4(~mode = Zip, src1, src2, src3, src4)
let zip5 = (src1, src2, src3, src4, src5) => ReStream_Through_Combine.make5(~mode = Zip, src1, src2, src3, src4, src5)
let zip6 = (src1, src2, src3, src4, src5, sr6) => ReStream_Through_Combine.make6(~mode = Zip, src1, src2, src3, src4, src5, sr6)


let drain = ReStream_Sink.drain
let abortableDrain = ReStream_Sink.abortableDrain
let drainToPromise = ReStream_Sink.drainToPromise
let collect = ReStream_Sink.collect
let collectToPromise = ReStream_Sink.collectToPromise





