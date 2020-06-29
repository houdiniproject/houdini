// License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
// Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
const _ = require('lodash');

const tsSpecBase = {
	parser: '@typescript-eslint/parser',
	plugins: [
		'@typescript-eslint',
		'jest'
	],
	extends: [
		'eslint:recommended',
		'plugin:@typescript-eslint/recommended',
		'plugin:jest/all'
	],
	rules:{
		"jest/lowercase-name": ["error", { "ignore": ["describe"]}]
	}
};

const tsSpec = _.cloneDeep(tsSpecBase);
tsSpec['files'] = ['**/*.spec.ts'];


module.exports = {
	root: true,

	overrides: [
		{
			"files": ['*.js', 'config/webpack/**/*.js'],
			extends: [
				'eslint:recommended',
				'plugin:node/recommended'
			],
		},
		{
			"files": ['**/*.ts'],
			parser: '@typescript-eslint/parser',
			plugins: [
				'@typescript-eslint',
			],
			extends: [
				'eslint:recommended',
				'plugin:@typescript-eslint/recommended',
			]
		},
		tsSpec
	],
	"rules": {
		"linebreak-style": [
			"error",
			"unix"
		],
		"semi": [
			"error",
			"always"
		],
		"no-trailing-spaces": ["error"],
		"indent": ["error", "tab"], // we use tabs for accessibility
	}
};
