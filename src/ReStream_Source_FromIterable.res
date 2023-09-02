type _iterable<'a>

type _iterator<'a> = unit => Promise.t<('a, bool)>

// let _getIterator :_iterable<'a> => _iterator<'a> = %raw(`
let _getIterator = %raw(`
	function (iterable) {
		if(iterable[Symbol.iterator]) {
			let iterator = iterable[Symbol.iterator]()
			return () => {
				let {value, done} = iterator.next()
				return Promise.resolve([value, done])
			}
			
		} else if(iterable[Symbol.asyncIterator]){
			let iterator = iterable[Symbol.asyncIterator]()
			return () => iterator.next().then(({value, done}) => [value, done])
		}
	}
`)

external _castArray :array<'a> => _iterable<'a> = "%identity"

let fromIterable = (iterable: _iterable<'a>) :ReStream_Source.readable<'a> => {

	let iterator = _getIterator(iterable)
	let done = ref(false)

	(sig :ReStream_Source.signal<'a>) => switch sig {
		| Pull(cb) when done.contents => cb(End)
		| Pull(cb) => {
				iterator()
				-> Promise.then(((value, _done)) => {
					if(_done) {
						done := true
						cb(End)
					} else {
						cb(Data(value))
					}
					Promise.resolve()
				})
				-> Promise.catch(err => {
					cb(Error(err))
					Promise.resolve()
				})
				-> ignore
			}
		| Abort => {
				done := true
			}
		}
		
	}
