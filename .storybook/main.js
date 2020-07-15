// License: LGPL-3.0-or-later
// Based on https://github.com/rails/webpacker/issues/1004#issuecomment-628377930
process.env.NODE_ENV = "development";
const railsWebpackEnv = require("../config/webpack/environment");

module.exports = {
  stories: ["../app/javascript/stories/*.[tj]s?(x)"],
  addons: ['@storybook/addon-actions', '@storybook/addon-links', 'storybook-addon-intl'],
  webpackFinal: (config) => ({
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
        .filter((i) => i.key !== "nodeModules")
        .map((i) => i.value),
    },
    plugins: [
      ...config.plugins,
      ...railsWebpackEnv.plugins.map((i) => i.value),
    ],
  }),
};
