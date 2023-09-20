# ReStream

Minimal pull-stream library written in [Rescript](https://rescript-lang.org/)

[![npm](https://img.shields.io/npm/v/@rsf/toy-stream.svg)](https://npmjs.org/@rsf/toy-stream)

## Installation

```shell
npm install @rsf/toy-stream
```
or
```shell
yarn add @rsf/toy-stream
```
Then add rescript-nodejs to `bsconfig.json`:
```
  "bs-dependencies": [
    "@rsf/toy-stream"
  ],
```

## Usage

```rescript
module S = ReStream

S.fromArray([1, 2, 3, 4])
-> S.map(v => "#" ++ Int.toString(v) )
-> S.collect(res => {
  switch res {
    | Ok(arr) => Console.log(arr)
    | Error(msg) => Console.log(msg)
  }
})
// #1
// #2
// #3
// #4
```

## API

[fromArray](tests/Test_sources.res#L8)  
[fromIterable](tests/Test_sources.res#L27)  
[fromWebStreamReadable](tests/Test_sources.res#L89)  

[actionable](tests/Test_actionable.res#L26)  
[observable](tests/Test_observable.res)  
[abortable](tests/Test_abortable.res)  

[log](src/ReStream_Through.res#27)  
[tap](src/ReStream_Through.res#20)  
[take](src/ReStream_Through.res#29)  

[debounce](tests/Test_debounce.res)  
[throttle](tests/Test_throttle.res)  
[timeout](src/ReStream_Through.res#83)  


[map](tests/Test_map.res#L4)  
[asyncMap](tests/Test_asyncMap.res#L4)  
[promiseMap](tests/Test_promiseMap.res#L4)  
[flatMap](tests/Test_flatMap.res#L4)  
[asyncFlatMap](tests/Test_flatMap.res#L24)  
[paraMap](tests/Test_paraMap.res)  

[filter](tests/Test_filter.res#4)  
[asyncFilter](tests/Test_filter.res#30)  
[filterMap](tests/Test_filter.res#58)  
[asyncFilterMap](tests/Test_filter.res#90)  

[group](tests/Test_group.res)  
[buffer](tests/Test_buffer.res)  

[mix](tests/Test_mix.res)  
[flatten](tests/Test_mix.res#107)  

[combineLatest](tests/Test_combineLatest.res)  
[zip](tests/Test_zip.res)  

[drain](src/ReStream_Sink.res#6)  
[abortableDrain](src/ReStream_Sink.res#28)  
[drainToPromise](src/ReStream_Sink.res#35)  
[collect](src/ReStream_Sink.res#47)  
[collectToPromise](src/ReStream_Sink.res#61)  
[toWebStreamReadable](tests/Test_sources.res#L71)  
