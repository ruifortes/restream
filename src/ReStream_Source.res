type payload<'a> =
	| Data('a)
	| End
	| Error(string)

type callback<'a> = payload<'a> => unit

type signal<'a> = Pull(callback<'a>) | Abort

type readable<'a> = signal<'a> => unit

type t<'a> = readable<'a>

let single = (value :'a) => {
	let done = ref(false)
	(sig :signal<'a>) => switch sig {
		| Pull(cb) when done.contents => cb(End)
		| Pull(cb) => done := true; cb(Data(value))	
		| Abort => done := true
		}
	}

let fromArray = (arr :array<'a>) :readable<'a> => {
	let count = Js.Array.length(arr)
	let currIndex = ref(0)

	(sig :signal<'a>) => {
		let i = currIndex.contents
		switch sig {
			| Pull(cb) when i < count => {
					currIndex := i + 1
					cb(Data(arr[i]))
				}
			| Pull(cb) => cb(End)
			| Abort => currIndex := count
			}
		}
		-> ignore

	}

let error = (err :string) => {
	(sig :signal<'a>) => switch sig {
		| Pull(cb) => cb(Error(err))
		| Abort => ()
		}
	}

// let error = (err :string) => {
// 	(sig :signal<'a>) => switch sig {
// 		| Pull(cb) => cb(Error(err))
// 		| Abort => ()
// 		}
// 	}
