// License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
// Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
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
		'plugin:jest/recommended',
		'plugin:jest/style',
		'plugin:react-hooks/recommended',
	],
	rules: {
		"jest/no-hooks": "off",
		"jest/lowercase-name": ["error", { "ignore": ["describe"] }],
		"react-hooks/exhaustive-deps": 'error',
		"jest/no-duplicate-hooks": 'error',
		"jest/prefer-hooks-on-top": 'warn',
	},
};


const tsSpec = _.cloneDeep(tsSpecBase);
tsSpec['files'] = ['**/*.spec.[j|t]s'];

const tsxSpec = _.cloneDeep(tsSpecBase);
tsxSpec['files'] = ['**/*.spec.tsx'];
tsxSpec['plugins'] = [...tsxSpec['plugins'], "react"];
tsxSpec['extends'] = [...tsxSpec['extends'], "plugin:react/recommended"];
tsxSpec['rules'] = {...tsxSpec['rules'], ...{"jest/no-hooks": "off"}};


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
		"semi": "off",
		"@typescript-eslint/semi": ["error", "always"],
		"no-trailing-spaces": ["error"],
		"indent": ["error", "tab", { "SwitchCase": 1 }], // we use tabs for accessibility
		"comma-dangle": "off",
		"@typescript-eslint/comma-dangle": ["error", "always-multiline"],
		"@typescript-eslint/no-unused-vars": ['error', { "args": "all", "argsIgnorePattern": "^_" }],
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
		"jest/no-hooks": "off",
	},
	"settings": {
		"react": {
			"version": "detect",
		},
	},
	extends: ["plugin:storybook/recommended"],
};
