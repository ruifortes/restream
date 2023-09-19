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
	let count = Array.length(arr)
	let currIndex = ref(0)

	let readable = (sig :signal<'a>) => {
		let i = currIndex.contents
		switch sig {
			| Pull(cb) when i < count => {
					currIndex := i + 1
					switch arr[i] {
						| Some(val) => cb(Data(val))
						| None => ()
					}
					
				}
			| Pull(cb) => cb(End)
			| Abort => currIndex := count
			}
		}
		
		readable

	}

let error = (err :string) => {
	
	let readable = (sig :signal<'a>) => switch sig {
		| Pull(cb) => cb(Error(err))
		| Abort => ()
		}

	readable
}
