open ReStream_Source

let make = (src: readable<'a>, src2: readable<unit>) :readable<array<'a>> => {

	let refDone = ref(false)
	let refPack = ref(false)
	let refArr: ref<array<'a>> = ref([])

	let rec getNext = cb => {
		src(Pull(payload => {
			let arr = refArr.contents

			switch payload {
				| Data(val) => {
						Array.push(arr, val)
						if(refPack.contents) {
							refPack := false
							refArr := []
							cb(Data(arr))
						} else {
							getNext(cb)
						} 						
					}
				| End => {
						refDone := true
						if(Array.length(arr) == 0) {
							cb(End)
						} else {
							cb(Data(arr))
						} 
					}
				| Error(err) => {
						refDone := true
						cb(Error(err))
					}
			}
		}))
	}

	src2
	-> ReStream_Through.tap(_ => refPack := true)
	-> ReStream_Sink.drain

	(sig :signal<array<'a>>) => {
		switch sig {
			| Pull(cb) when refDone.contents => cb(End)
			| Pull(cb) => getNext(cb)
			| Abort => src(Abort)
			}
		}	

}