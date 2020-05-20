process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')
environment.splitChunks((config) => {
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
    return Object.assign({}, config, excludeDonateButtonFromSplit)
})
module.exports = environment.toWebpackConfig()
