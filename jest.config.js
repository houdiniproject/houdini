module.exports =  {
	"testEnvironment": "jest-environment-jsdom-fifteen",
	"testEnvironmentOptions": {
		"enzymeAdapter": "react16"
	},
	"globals": {
		"ts-jest": {
			"babelConfig": false
		}
	},
	"setupFiles": [
		"<rootDir>/setupTests.js"
	],
	"transform": {
		"^.+\\.tsx?$": "ts-jest"
	},
	"testPathIgnorePatterns": [
		"/node_modules/",
		"/config/webpack/test.js",
		"/vendor/"
	],
	"testRegex": "(/__tests__/.*|(\\.|/)(test|spec))\\.(jsx?|tsx?)$",
	"moduleFileExtensions": [
		"ts",
		"tsx",
		"js",
		"jsx",
		"json",
		"node"
	],
	"snapshotSerializers": [
		"enzyme-to-json/serializer"
	]
}