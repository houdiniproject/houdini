module.exports = {
  module: {
    rules: [
      {
        test: /\.erb$/,
        enforce: 'pre',
        exclude: /node_modules/,
        use: 'rails-erb-loader'
      }
    ]
  }
}
