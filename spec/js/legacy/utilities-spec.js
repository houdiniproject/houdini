var utils = require("../../../app/assets/javascripts/common/utilities")

var fruit = { name: "banana", color: "yellow", flavor: "sweet" }
var vegetable = { name: "corn", color: "yellow", season: "summer"}

describe("utils.vals", function() {
	it("takes an object and returns an array of values", function() {
		expect(utils.vals(fruit)).toEqual(["banana", "yellow", "sweet"])
	})
})

describe("utils.keys", function() {
	it("takes an object and returns an array of keys", function() {
		expect(utils.keys(fruit)).toEqual(["name", "color", "flavor"])
	})
})

describe("utils.zero_pad", function() {
	it("takes an initial number and the desired length of the number \
		and returns the initial number with with zero's prepended to it", function() {
		expect(utils.zero_pad(666, 10)).toBe("0000000666")
	})
})

describe("utils.simple_date_from_string", function() {
	it("takes a loose string representation of a date and \
		returns a uniform representaion", function() {
		expect(utils.simple_date_from_string("Sun, 27 Sep 2015 12:00:00 UTC")).toBe("09/27/2015")
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

describe("utils.trim", function() {
	it("takes a string and removes any leading or trailing white space", function() {
		expect(utils.trim('    whoa!    ')).toBe('whoa!')
	})
})

describe("utils.flatten", function() {
	it("takes an array of arrays and returns one flattened array", function() {
		expect(utils.flatten([[1,2],[3,4]])).toEqual([1,2,3,4])
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


// pending...

xdescribe("utils.get_param", function() {
	var location = {}

	beforeAll(function() {
		location.search = '?id=666'
	})
	afterAll(function() {
		location.search = ''
	})
	xit("returns url params as a string", function() {
		expect(utils.get_param('id')).toEqual('666')
	})
})


xdescribe("utils.toFormData", function() {
	xit("takes a form and returns an object using the form inputs' attribute names as keys ", function() {
		expect(utils.foFormData(form_object)).toBe('....')
	})
})

