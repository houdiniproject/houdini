const { environment } = require('@rails/webpacker')
const ForkTsCheckerWebpackPlugin = require("fork-ts-checker-webpack-plugin");
const path = require("path");
const erb = require('./loaders/erb')

environment.loaders.prepend('erb', erb)
environment.plugins.append(
    "ForkTsCheckerWebpackPlugin",
    new ForkTsCheckerWebpackPlugin({
      // this is a relative path to your project's TypeScript config
      tsconfig: path.resolve(__dirname, "../../tsconfig.json"),
      // non-async so type checking will block compilation
      async: false,
    })
  );
module.exports = environment
