// AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
const path = require ('path')
const WebpackSweetEntry = require('webpack-sweet-entry');
const CleanWebpackPlugin = require('clean-webpack-plugin');
const ExtractTextPlugin = require("extract-text-webpack-plugin");
const webpack = require("webpack");
const CopyWebpackPlugin = require('copy-webpack-plugin')
const merge = require('webpack-merge');
const CompressionPlugin = require("compression-webpack-plugin");
const UglifyJsPlugin = require('uglifyjs-webpack-plugin')

const config_button=require('./config/settings.json');

const sourcePath = path.join(__dirname, 'client');
const buildPath = path.join(__dirname, 'public/client');
const translationPath = path.join(__dirname, 'public/javascripts/_final.js')
const reactEntrySourcePath = path.join(__dirname, 'javascripts')
const reactEntryOutputPath = path.join(__dirname, 'public')


let inProduction = process.env.NODE_ENV === 'production'

let devToProdLibraries = {
  react:{
    debug: "node_modules/react/umd/react.development.js",
    production: "node_modules/react/umd/react.production.min.js"
  },
  reactDom: {
    debug: "node_modules/react-dom/umd/react-dom.development.js",
    production: "node_modules/react-dom/umd/react-dom.production.min.js"
  }
}



let common_rules= [

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


let targets = {
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
            ],
        resolve: {
            extensions: ['.ts', '.tsx', '.js', '.es6']
        },
    }
    ,
    button: {
        module:{
            rules: common_rules
        },
        entry: path.resolve(sourcePath, 'js/widget/donate-button.v2.js'),
        output: {
            path: path.resolve(path.join(__dirname, 'public', 'js')),
            filename: 'donate-button.v2.js'
        },
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
    bootstrap: {
      module:{
        rules: [
            { test: /\.(woff2?|svg)$/, loader: 'url-loader?limit=10000' },
            { test: /\.(ttf|eot)$/, loader: 'file-loader' },
        ]
      },
        entry: ['bootstrap-loader'],
        output: {
          path: path.resolve(buildPath, 'css'),
          filename: 'bootstrap.css'
        },
      plugins: [
        new ExtractTextPlugin('bootstrap.css')
      ]
    },
    loading_indicator: {
      module:{
        rules: common_rules
      },
      entry: path.resolve(reactEntrySourcePath, "app", "loading_indicator.ts"),
      output: {
        path: path.resolve(reactEntryOutputPath, 'app'),
        filename: 'loading_indicator.js'
      },

    },
    react: {
        module:{
            rules: common_rules
        },
        entry: WebpackSweetEntry(path.resolve(reactEntrySourcePath, "app/*.tsx"), 'ts', 'app'),
        output: {
            path: path.resolve(reactEntryOutputPath, 'app'),
            filename: '[name].js'
        },
        resolve: {
            extensions: [".ts", ".tsx", ".js", ".json"],
        },
        plugins: [
            new CleanWebpackPlugin([path.resolve(reactEntryOutputPath, 'app')]),
            new webpack.optimize.CommonsChunkPlugin({
                name: 'vendor',
            }),
            new CopyWebpackPlugin([{from: inProduction ? devToProdLibraries.react.production : devToProdLibraries.react.debug, to: path.resolve('public', 'app', 'react.js')}]),
            new CopyWebpackPlugin([{from: inProduction ? devToProdLibraries.reactDom.production : devToProdLibraries.reactDom.debug, to:path.resolve('public', 'app', 'react-dom.js')}])

        ],
        externals: {
            'react': 'React',
            'react-dom': 'ReactDOM',
            'i18n': 'I18n'
        }
    }
}

let mergeToTargets = {
  devtool: 'inline-source-map',
}

if (inProduction)
    mergeToTargets = {
        plugins: [
            new UglifyJsPlugin(),
            new CompressionPlugin({
              asset: '[path].gz'
            })
          ]}
let output = []
for(let name in targets){
  output.push(merge(targets[name], mergeToTargets));
}


module.exports = output