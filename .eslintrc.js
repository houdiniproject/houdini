// License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
// Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
const _ = require('lodash');

const tsSpecBase = {
	parser: '@typescript-eslint/parser',
	plugins: [
		'@typescript-eslint',
		'jest',
	],
	extends: [
		'eslint:recommended',
		'plugin:@typescript-eslint/recommended',
		'plugin:jest/all',
	],
	rules: {
		"jest/lowercase-name": ["error", { "ignore": ["describe"] }],
	},
};


const tsSpec = _.cloneDeep(tsSpecBase);
tsSpec['files'] = ['**/*.spec.ts'];

const tsxSpec = _.cloneDeep(tsSpecBase);
tsxSpec['files'] = ['**/*.spec.tsx'];
tsxSpec['plugins'] = [...tsxSpec['plugins'], "react"];
tsxSpec['extends'] = [...tsxSpec['extends'], "plugin:react/recommended"];


const tsBase = {
	parser: '@typescript-eslint/parser',
	plugins: [
		'@typescript-eslint',
	],
	extends: [
		'eslint:recommended',
		'plugin:@typescript-eslint/recommended',
		"plugin:react-hooks/recommended",
	],
};

const tsSettings = _.cloneDeep(tsBase);
tsSettings['files'] = ['**/*.ts'];

const tsxSettings = _.cloneDeep(tsBase);
tsxSettings['files'] = ['**/*.tsx'];
tsxSettings['plugins'] = [...tsxSpec['plugins'], "react"];
tsxSettings['extends'] = [...tsxSpec['extends'], "plugin:react/recommended"];

module.exports = {
	root: true,
	overrides: [
		{
			"files": ['*.js', 'config/webpack/**/*.js'],
			extends: [
				'eslint:recommended',
				'plugin:node/recommended',
			],
		},
		tsSpec,
		tsxSpec,
		tsSettings,
		tsxSettings,
	],
	"rules": {
		"linebreak-style": [
			"error",
			"unix",
		],
		"semi": [
			"error",
			"always",
		],
		"no-trailing-spaces": ["error"],
		"indent": ["error", "tab", {"SwitchCase": 1}], // we use tabs for accessibility
		"comma-dangle": ["error", "always-multiline"],
	},
	"settings": {
		"react": {
			"version": "detect",
		},
	},
};
