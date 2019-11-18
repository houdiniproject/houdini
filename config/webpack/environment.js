const { environment } = require('@rails/webpacker')
const erb = require('./loaders/erb')
const typescript =  require('./loaders/typescript')

environment.loaders.prepend('typescript', typescript)

environment.loaders.prepend('erb', erb)

module.exports = environment
