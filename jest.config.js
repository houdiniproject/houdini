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
	"modulePathIgnorePatterns": [
		"<rootDir>/vendor", // don't go to the gems vendor folder. EVER.
	],
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
		"/tmp/",
		"/public/",
		"/storage/",
		"/log/",
		"/coverage/",
		"/.vscode/",
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
		"\\.(jpg|jpeg|png|gif|eot|otf|webp|svg|ttf|woff|woff2|mp4|webm|wav|mp3|m4a|aac|oga)$": "<rootDir>/app/javascript/__mocks__/fileMock.js",
		"\\./regenerate.js": "<rootDir>/app/javascript/__mocks__/erbMock.js",
	},
};