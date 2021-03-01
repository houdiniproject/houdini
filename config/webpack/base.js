const { webpackConfig, merge } = require('@rails/webpacker')

const erbConfig = require('./rules/erb')

const cssConfig = require('./rules/css')
const tsConfig = require('./rules/ts')

module.exports = merge(webpackConfig, tsConfig, cssConfig, erbConfig);
