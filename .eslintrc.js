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
		'plugin:react-hooks/recommended',
	],
	rules: {
		"jest/lowercase-name": ["error", { "ignore": ["describe"] }],
		"react-hooks/exhaustive-deps": 'error',
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
		{
			"files": ['*.stories.ts', '*.stories.tsx'],
			"rules": {
				"@typescript-eslint/explicit-module-boundary-types": ["off"],
			},
		},
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
		"indent": ["error", "tab", { "SwitchCase": 1 }], // we use tabs for accessibility
		"comma-dangle": "off",
		"@typescript-eslint/comma-dangle": ["error", "always-multiline"],
		"@typescript-eslint/no-unused-vars": ['error', { "args": "all", "argsIgnorePattern": "^_" }],
		'@typescript-eslint/member-ordering': ['error',
			{
				// this is the default from @typescript-eslint itself
				"default": {
					"memberTypes": [
						// Index signature
						"signature",

						// Fields
						"public-static-field",
						"protected-static-field",
						"private-static-field",

						"public-decorated-field",
						"protected-decorated-field",
						"private-decorated-field",

						"public-instance-field",
						"protected-instance-field",
						"private-instance-field",

						"public-abstract-field",
						"protected-abstract-field",
						"private-abstract-field",

						"public-field",
						"protected-field",
						"private-field",

						"static-field",
						"instance-field",
						"abstract-field",

						"decorated-field",

						"field",

						// Constructors
						"public-constructor",
						"protected-constructor",
						"private-constructor",

						"constructor",

						// Methods
						"public-static-method",
						"protected-static-method",
						"private-static-method",

						"public-decorated-method",
						"protected-decorated-method",
						"private-decorated-method",

						"public-instance-method",
						"protected-instance-method",
						"private-instance-method",

						"public-abstract-method",
						"protected-abstract-method",
						"private-abstract-method",

						"public-method",
						"protected-method",
						"private-method",

						"static-method",
						"instance-method",
						"abstract-method",

						"decorated-method",

						"method",
					],
					"order": "alphabetically",
				},
			},
		],
		'@typescript-eslint/member-delimiter-style': ['error',
			{
				"multiline": {
					"delimiter": "semi",
					"requireLast": true,
				},
				"singleline": {
					"delimiter": "comma",
					"requireLast": false,
				},
			},
		],
		"react-hooks/exhaustive-deps": 'error',
	},
	"settings": {
		"react": {
			"version": "detect",
		},
	},
};
