const { environment } = require('@rails/webpacker')
const ForkTsCheckerWebpackPlugin = require("fork-ts-checker-webpack-plugin");
const path = require("path");
const erb = require('./loaders/erb')

environment.loaders.prepend('erb', erb)
environment.plugins.append(
  "ForkTsCheckerWebpackPlugin",
  new ForkTsCheckerWebpackPlugin({
    typescript: {
      tsconfig: path.resolve(__dirname, "../../tsconfig.json"),
    },
    async: false,
  })
);
module.exports = environment
