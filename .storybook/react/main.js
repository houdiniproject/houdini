// License: LGPL-3.0-or-later
// Based on https://github.com/rails/webpacker/issues/1004#issuecomment-628377930
process.env.NODE_ENV = "development";
const railsWebpackEnv = require("../../config/webpack/environment");

module.exports = {
  stories: [
    "../../app/javascript/**/*!(--html).stories.mdx",
    "../../app/javascript/**/*!(--html).stories.[tj]s?(x)"
  ],
  addons: [
    "@storybook/addon-links",
    "@storybook/addon-essentials",
    'storybook-addon-intl'
  ],
  webpackFinal: (config) => {
    const result = {
    // do mutation to the config
    ...config,
    resolve: {
      ...config.resolve,
      ...railsWebpackEnv.config.resolve,
      modules: railsWebpackEnv.resolvedModules.map((i) => i.value),
    },
    module: {
      ...config.module,
      rules: railsWebpackEnv.loaders
        .filter((i) => !["nodeModules", //not sure why this is here
        "moduleCss" // this addresses issues with our webpack config for css not matching what storybook wants
      ].includes(i.key) )
        .map((i) => i.value),
    },
    plugins: [
      ...config.plugins,
      ...railsWebpackEnv.plugins.map((i) => i.value),
    ],
    
  };

  result.module.rules.filter((i) => i.test.test('.ttf')).forEach((i) => {
    i.use=['url-loader']
  })

  result.resolve
    .alias[require.resolve(
      '../../app/javascript/legacy_react/src/lib/api/sign_in.ts')] = require.resolve(
        '../../app/javascript/legacy_react/src/lib/api/__mocks__/sign_in.ts')


  return result
},
};
