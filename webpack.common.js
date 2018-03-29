// AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
const path = require ('path')
const WebpackSweetEntry = require('webpack-sweet-entry');
const CleanWebpackPlugin = require('clean-webpack-plugin');
const StringReplacePlugin = require("string-replace-webpack-plugin");
const ExtractTextPlugin = require("extract-text-webpack-plugin");
const ProvidePlugin = require('webpack').ProvidePlugin

const config_button=require('./config/settings.json');

const sourcePath = path.join(__dirname, 'client');
const buildPath = path.join(__dirname, 'public/client');
const translationPath = path.join(__dirname, 'public/javascripts/_final.js')
const reactEntrySourcePath = path.join(__dirname, 'javascripts')
const reactEntryOutputPath = path.join(__dirname, 'public')

var common_rules= [

        // configure replacements for file patterns
        {
            test: /donate-button.v2.js$/,
            loader: [
                {loader: 'string-replace-loader',
                    options: {
                        search: 'REPLACE_FULL_HOST',
                        replace: config_button.button.url,
                    },
                },
                {
                    loader: 'string-replace-loader',
                    options: {
                        search: 'REPLACE_CSS_URL',
                        replace: config_button.button.css,
                    },
                },
                "babel-loader"]
        },
        { test: /\.tsx?$/, loader:"ts-loader"},
        { test: /\.js$/, exclude: /node_modules|froala/, loader: "babel-loader" },
        { test: /\.es6$/, exclude: /node_modules/, loader: "babel-loader" }
]
module.exports = {
    base: {
        module:{
            rules: common_rules
        },
        entry: WebpackSweetEntry(path.resolve(sourcePath, 'js/**/page.js'), 'js', 'js'),
        output: {
            path: path.resolve(buildPath, 'js'),
            filename: '[name].js'
        },
        plugins: [
                 new CleanWebpackPlugin([path.resolve(buildPath, 'js')])
            ]
    }
    ,
    // translations: {
    //     module:{
    //         rules: common_rules
    //     },
    //     entry: path.resolve(sourcePath, 'js/translations/translations.js'),
    //     output: {
    //         path: path.resolve(buildPath, 'js/nonprofits/donate/'),
    //         filename: 'i18n.js'
    //     },

    // },
    button: {
        module:{
            rules: common_rules
        },
        entry: path.resolve(sourcePath, 'js/widget/donate-button.v2.js'),
        output: {
            path: path.resolve(path.join(__dirname, 'public', 'js')),
            filename: 'donate-button.v2.js'
        },

        plugins: [
            // an instance of the plugin must be present
            new StringReplacePlugin()
        ]
    },
    translations: {
        module:{
            rules: common_rules
        },
        entry: translationPath,
        output: {
            path: path.join(buildPath, 'js'),
            filename: 'i18n.js'
        }
    },
    css: {
        module: {
            rules: [
                {
                    test: /\.css$/,
                    use: ExtractTextPlugin.extract({
                            use: [
                                {
                                    loader: 'css-loader',
                                    options: {import: true, importLoaders: 1}
                                }
                                , 'postcss-loader']
                        }
                    )
                },
            ]
        },
        entry: path.resolve(sourcePath, 'css/global/page.css'),
        output: {
            path: path.resolve(buildPath, 'css/global'),
            filename: 'page.css'
        },
        plugins: [
            new ExtractTextPlugin('page.css'),
            new CleanWebpackPlugin([path.resolve(buildPath, 'css')])
        ]
    },
    react: {
        module:{
            rules: common_rules
        },
        entry: WebpackSweetEntry(path.resolve(reactEntrySourcePath, "app/*.ts"), 'ts', 'app'),
        output: {
            path: path.resolve(reactEntryOutputPath, 'app'),
            filename: '[name].js'
        },
        resolve: {
            extensions: [".ts", ".tsx", ".js", ".json"],
        },
        plugins: [
            new CleanWebpackPlugin([path.resolve(reactEntryOutputPath, 'app')])
        ]
    }
}
