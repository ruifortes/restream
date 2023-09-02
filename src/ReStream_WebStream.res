// [Web Streams API | Node.js v16.5.0 Documentation](https://nodejs.org/api/webstreams.html#webstreams_new_readablestream_underlyingsource_strategy)
// [ReadableStream - Web APIs | MDN](https://developer.mozilla.org/en-US/docs/Web/API/ReadableStream)
module Promise = Js.Promise

type _reader<'a>
type _payload<'a> = {
	done :bool,
	value: 'a
}

type _controller<'a>
type _underlyingSource<'a> = {
	pull :_controller<'a> => Promise.t<Js.undefined<unit>>,
	cancel :string => unit
}

@new external _makeReadableStream :_underlyingSource<'a> => Webapi.ReadableStream.t = "ReadableStream"

@send external _getReader :(Webapi.ReadableStream.t) => _reader<'a> = "getReader"
@send external _cancel :(_reader<'a>) => Promise.t<unit> = "cancel"
// @send external _cancel :(Webapi.ReadableStream.t) => unit = "cancel"
@send external _read :_reader<'a> => Promise.t<_payload<'a>> = "read"
@send external _callEnqueue :(_controller<'a>, 'a) => unit = "enqueue"
@send external _callClose :(_controller<'a>) => unit = "close"
@send external _callError :(_controller<'a>, string) => unit = "error"
// @send external _callError :(_controller<'a>, exn) => unit = "error"

let fromWebStreamReadable = (readable :Webapi.ReadableStream.t) :ReStream_Source.readable<'a> => {
	let reader = _getReader(readable)
	(sig :ReStream_Source.signal<'a>) => {
		switch sig {
			| Pull(cb) => {
				_read(reader)
				-> Promise.then_(({done, value}) => {
						if (done) {
							cb(End)
						} else {
							cb(Data(value))
						}
						Promise.resolve()
					}, _)
				-> Promise.catch(err => {
						cb(Error(Js.String.make(err)))
						Promise.resolve()
					}, _)
				-> ignore
			}
			| Abort => {
					reader -> _cancel -> ignore
				}
			}
		}

}

let toWebStreamReadable = (src :ReStream_Source.readable<'a>) :Webapi.ReadableStream.t => {

	let push = controller => {
		Promise.make((~resolve, ~reject) => {	
			src(Pull(payload => {
				switch payload {
					| Data(val) => controller -> _callEnqueue(val)
					| End => controller -> _callClose
					| Error(err) => controller -> _callError(err)
					}
					resolve(. Js.Undefined.empty)
				}))
		})
	}

	let webStream = _makeReadableStream({
		pull: push,
		cancel: reason => src(Abort)
	})

	webStream

}
