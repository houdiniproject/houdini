// License: LGPL-3.0-or-later
const utils = require("./utilities")

var fruit = { name: "banana", color: "yellow", flavor: "sweet" }
var vegetable = { name: "corn", color: "yellow", season: "summer"}

describe("utils.zero_pad", function() {
	it("takes an initial number and the desired length of the number \
		and returns the initial number with with zero's prepended to it", function() {
		expect(utils.zero_pad(666, 10)).toBe("0000000666")
	})
})

describe("utils.number_with_comma", function() {
	it("takes a number and returns a string with the number \
		seperated by a comma at every three digits", function() {
		expect(utils.number_with_commas(6666666666666)).toBe("6,666,666,666,666")
	})
})

describe("utils.merge", function() {
	it("takes two objects and merges them (favors second object's \
		values if the objects have same keys) ", function() {
		expect(utils.merge(fruit, vegetable)).toEqual({name: "corn", color: "yellow", flavor: "sweet", season: "summer"})
	})
})

describe("utils.cents_to_dollars", function() {
	it("takes a number representing an amount in cents and returns \
		that amount representing a dollars", function() {
		expect(utils.cents_to_dollars(666)).toBe("6.66")
	})
})

describe("utils.dollars_to_cents", function() {
	it("takes a number representing an amount in dollars and returns \
		that amount representing cents", function() {
		expect(utils.dollars_to_cents(6.66)).toBe(666)
	})
})

describe("utils.uniq", function() {
	it("takes an array and returns the array with no duplicates", function() {
		expect(utils.uniq(['beer', 'wine', 'beer', 'mescal', 'beer', 'wine'])).toEqual(['beer', 'wine', 'mescal'])
	})
})

describe("utils.address_with_commas", function() {
	it("takes a street, address and state and return them seperated by commas", function() {
		expect(utils.address_with_commas('1600 Pennsylvania Ave NW', 'Washington', 'DC' )).toEqual('1600 Pennsylvania Ave NW, Washington, DC')
	})
})

