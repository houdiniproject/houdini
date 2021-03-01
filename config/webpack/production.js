const { merge, mergeWithCustomize } = require('@rails/webpacker')
process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const webpackConfig = require('./base')

function outputLicenseFile(file, outputDir) {
	const contents = fs.readFileSync(file);
	const name =  path.basename(file) + "-" + hash(contents) + ".txt";
	if (!fs.existsSync(outputDir)) {
		fs.mkdirSync(outputDir, {recursive: true});
	}
	fs.copyFileSync(file, path.join(outputDir, name));

	return name;

}


const terserAdded = mergeWithCustomize({
  customizeArray: unique(
    "optimization.minimizer",
    ["TerserPlugin"],
    (plugin) => plugin.constructor && plugin.constructor.name
  ),
})(
  webpackConfig,
  new TerserPlugin({
		parallel: Number.parseInt(process.env.WEBPACKER_PARALLEL, 10) || true,
		terserOptions: {
			parse: {
				// Let terser parse ecma 8 code but always output
				// ES5 compliant code for older browsers
				ecma: 8
			},
			compress: {
				ecma: 5,
				warnings: false,
				comparisons: false
			},
			mangle: { safari10: true },
			output: {
				ecma: 5,
				comments: /@hlicense/i,
				ascii_only: true
			},
			extractComments: false
		}
	})
);

const bannerConfig = {

	plugins: [new webpack.BannerPlugin(
		{banner: `@hlicense License information is available at ${config.publicPath}${outputLicenseFile('NOTICE-js', config.outputPath)}`,
	entryOnly: false})]
}

const excludeDonateButtonFromSplit = {
	optimization:
	{
			splitChunks:
			{
					chunks(chunk) {
							// donate-button-v2 can never be split. So don't
							return chunk.name !== 'donate-button-v2'
					}
			},
			// we can't have the donate-button-v2 ONLY include runtimeChunk
			// so we never split it out. 🙁
			runtimeChunk: false
	},
}

module.exports = merge(terserAdded, bannerConfig, excludeDonateButtonFromSplit)
