const { environment, config } = require('@rails/webpacker')
const ForkTsCheckerWebpackPlugin = require("fork-ts-checker-webpack-plugin");
const webpack = require('webpack');
const path = require("path");
const erb = require('./loaders/erb')
const fs = require('fs')
const hash = require('object-hash')

function getTerser() {
  if(environment.config && 
    environment.config.optimization && 
    environment.config.optimization.minimizer && 
    environment.config.optimization.minimizer instanceof Array &&
    environment.config.optimization.minimizer.length === 1)
    return environment.config.optimization.minimizer[0]
  else 
    return null;
}

function outputLicenseFile(file, outputDir) {
	const contents = fs.readFileSync(file);
	const name =  path.basename(file) + "-" + hash(contents) + ".txt";
	if (!fs.existsSync(outputDir)) {
		fs.mkdirSync(outputDir, {recursive: true});
	}
	fs.copyFileSync(file, path.join(outputDir, name));

	return name;

}



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

environment.plugins.prepend("BannerPlugin", new webpack.BannerPlugin(
  {banner: `@hlicense License information is available at ${config.publicPath}${outputLicenseFile('NOTICE-js', config.outputPath)}`,
entryOnly: false}))


const terser = getTerser()
if (terser) {
  terser.options.terserOptions = terser.options.terserOptions || {}
  terser.options.terserOptions.output = terser.options.terserOptions.output || {} 
  terser.options.terserOptions.output.comments = /@hlicense/i

  // we don't want terser to print out license headers, we'll handle that ourselves
  terser.options.extractComments = false;
}


module.exports = environment
