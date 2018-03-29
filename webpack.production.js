// License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
const merge = require('webpack-merge');
const UglifyJSPlugin = require('uglifyjs-webpack-plugin');
const CompressionPlugin = require("compression-webpack-plugin");
const common = require('./webpack.common.js');

const common_stuff = {
    plugins: [
        new UglifyJSPlugin(),
        new CompressionPlugin({
            asset: '[path].gz'
        })
    ]
}

module.exports = [
    merge(common.translations, common_stuff),
    merge(common.base, common_stuff),
    merge(common.button, common_stuff),
    merge(common.css, common_stuff),
    merge(common.react, common_stuff),
]
