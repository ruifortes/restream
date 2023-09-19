# ReStream

This is a minimal pull-stream library written in [Rescript](https://rescript-lang.org/)

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

