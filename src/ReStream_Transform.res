open ReStream_Source

let map = (src :readable<'a>, mapper :'a => 'b) :readable<'b> => {

	(sig :signal<'b>) => {
		switch sig {
			| Pull(cb) => src(Pull(payload =>
				switch payload {
					| Data(val) => Data(mapper(val)) -> cb
					| End => cb(End)
					| Error(err) => cb(Error(err))
					}
				))
			| Abort => src(Abort)
			}
		}

}


let asyncMap = (src :readable<'a>, mapper :('a, 'b => unit) => unit) :readable<'b> => {

	(sig :signal<'b>) => {
		switch sig {
			| Pull(cb) => {
				src(Pull(payload => 
					switch payload {
						| Data(pVal) => {
								mapper(pVal, (nVal :'b) => {
									Data(nVal) -> cb
								})
							}
						| End => cb(End)
						| Error(err) => cb(Error(err))
						}
					))
				}
			| Abort => src(Abort)
			}
		}

	}


let promiseMap = (src :readable<'a>, mapper : 'a => Promise.t<'b>) :readable<'b> => {
	(sig :signal<'b>) => {
		switch sig {
			| Pull(cb) => src(Pull(payload =>
				switch payload {
					| Data(v) => {
							let _ = mapper(v)
							-> Promise.then(ret => {
									cb(Data(ret))
									Promise.resolve()
								})
							-> Promise.catch(err => {
									cb(Error(String.make(err)))
									Promise.resolve()
								})
						}
					| End => cb(End)
					| Error(err) => cb(Error(err))
					}
				))
			| Abort => src(Abort)
			}
			()
		}
	}


