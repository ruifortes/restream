open Test

let boolEqual = (~message=?, a: bool, b: bool) =>
	assertion(~message?, ~operator="Int equal", (a, b) => a === b, a, b)

let intEqual = (~message=?, a: int, b: int) =>
	assertion(~message?, ~operator="bool equal", (a, b) => a === b, a, b)

let arrayDeepEqual = (~message=?, a: array<'a>, b: array<'a>) => {

	let comparator = (a, b) => Belt.Array.eq(a, b, (a, b) => a === b)
		
	assertion(~message?, ~operator="Array Deep Equal", comparator, a, b)
	
}

let arraySameItems = (~message=?, a: array<'a>, b: array<'a>) => {
	let comparator = (a, b) => {
		Belt.Array.length(a) == Belt.Array.length(b)
		&&
		a -> Belt.Array.every(v1 => {
			b -> Belt.Array.getBy(v2 => v1 === v2)
			-> Belt.Option.isSome
		})
		

	}

	assertion(~message?, ~operator="Array with Same Items", comparator, a, b)
}