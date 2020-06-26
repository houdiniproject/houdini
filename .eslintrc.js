// License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
// Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE


module.exports = {
	root: true,

	overrides: [
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
		}
	],
	"rules": {
		"linebreak-style": [
			"error",
			"unix"
		],
		"semi": [
			"error",
			"never"
		]
	}
};
