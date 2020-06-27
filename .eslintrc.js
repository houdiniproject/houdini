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
    },
    {
            "files": ['**/*.spec.ts'],
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
          }
	],
	"rules": {
		"linebreak-style": [
			"error",
			"unix"
		],
		"semi": [
			"error",
			"always"
		]
	}
};
