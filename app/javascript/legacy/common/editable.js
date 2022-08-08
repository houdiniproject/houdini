// License: LGPL-3.0-or-later
// if you are instantiating more than one WYSIWYG on a page,
// be sure to give them id's to differentiate them
// to avoid unwanted display side effects


if (app.editor === 'quill')
	module.exports = require('./editor/quill.js')
