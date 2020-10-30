module.exports =  {
	"testEnvironment": "jest-environment-jsdom-fifteen",
	"testEnvironmentOptions": {
		"enzymeAdapter": "react16",
	},
	"globals": {
		"ts-jest": {
			"babelConfig": false,
		},
	},
	"setupFiles": [
		"<rootDir>/setupTests.js",
	],
	"transform": {
		"^.+\\.tsx?$": "ts-jest",
	},
	"testPathIgnorePatterns": [
		"/node_modules/",
		"/config/webpack/test.js",
		"/vendor/",
	],
	"testRegex": "(/__tests__/.*|(\\.|/)(test|spec))\\.(jsx?|tsx?)$",
	"moduleFileExtensions": [
		"ts",
		"tsx",
		"js",
		"jsx",
		"json",
		"node",
	],
	"snapshotSerializers": [
		"enzyme-to-json/serializer",
	],
	"moduleNameMapper": {
		"\\.(jpg|jpeg|png|gif|eot|otf|webp|svg|ttf|woff|woff2|mp4|webm|wav|mp3|m4a|aac|oga)$": "<rootDir>/__mocks__/fileMock.js",
		"\\.erb.(js|ts)": "<rootDir>/__mocks__/erbMock.js",
	},
};