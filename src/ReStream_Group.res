open ReStream_Source

let make = (src :readable<'a>, size :int) :readable<array<'a>> => {

	let refDone = ref(false)
	let refArr: ref<array<'a>> = ref([])

	let rec getNext = cb => {
		src(Pull(payload => {
			let arr = refArr.contents

			switch payload {
				| Data(val) => {
						Array.push(arr, val)
						let len = Array.length(arr)
						if(size == 0 || len < size) {
							getNext(cb)
						} else {
							refArr := []
							cb(Data(arr))
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

	(sig :signal<array<'a>>) => {
		switch sig {
			// | Pull(cb) when refDone.contents => cb(End)
			| Pull(cb) => getNext(cb)
			| Abort => src(Abort)
			}
		}	

}