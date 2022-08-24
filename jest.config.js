module.exports =  {
	"testEnvironmentOptions": {
		"enzymeAdapter": "react17",
	},
	"globals": {
		"ts-jest": {
			"babelConfig": false,
			"isolatedModules": true,
		},
	},
	"collectCoverage": false,
	"modulePathIgnorePatterns": [
		"<rootDir>/vendor", // don't go to the gems vendor folder. EVER.
		"<rootDir>/tmp",
		"<rootDir>/vendor",
		"<rootDir>/storage",
		"<rootDir>/log",
		"<rootDir>/.vscode",
	],
	"moduleFileExtensions":["ts", "tsx", "js", "json", "jsx", "node"],
	"moduleNameMapper": {
		"\\.(jpg|jpeg|png|gif|eot|otf|webp|svg|ttf|woff|woff2|mp4|webm|wav|mp3|m4a|aac|oga)$": "<rootDir>/app/javascript/__mocks__/fileMock.js",
		"\\./regenerate.js": "<rootDir>/app/javascript/__mocks__/erbMock.js",
	},
	"setupFiles": [
		"<rootDir>/setupTests.js",
	],
	"setupFilesAfterEnv": [
		"<rootDir>/setupTestsAfterEnvLoaded.ts",
	],
	"snapshotSerializers": [
		"enzyme-to-json/serializer",
	],
	"transform": {
		"^.+\\.tsx?$": "babel-jest",
	},
	"transformIgnorePatterns": [
		"<rootDir>/node_modules/(?!lodash-joins/)",
		"<rootDir>/config/webpack/test.js",
		"<rootDir>/vendor/",
		"<rootDir>/tmp/",
		"<rootDir>/public/",
		"<rootDir>/storage/",
		"<rootDir>/log/",
		"<rootDir>/coverage/",
		"<rootDir>/.vscode/",
	],
	"testPathIgnorePatterns": [
		"<rootDir>/node_modules/",
		"<rootDir>/config/webpack/test.js",
		"<rootDir>/vendor/",
		"<rootDir>/tmp/",
		"<rootDir>/public/",
		"<rootDir>/storage/",
		"<rootDir>/log/",
		"<rootDir>/coverage/",
		"<rootDir>/.vscode/",
	],
	"testMatch":[ "<rootDir>/app/**/?(*.)+(spec|test).[jt]s?(x)" ],
};