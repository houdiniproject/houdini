// License: LGPL-3.0-or-later
var view = require("vvvview")
var savingIndicator = require('../../components/saving_indicator')
var savingState = {hide: true}
var renderSavingIndicator = view(savingIndicator, document.body, savingState)


const Quill = require('quill')

function initializeQuill($el, options)
{
    var editor = new Quill($el, {
        theme: 'bubble',
        placeholder: options.placeholder
    });

    if (!options.noUpdateOnChange) {
        editor.on('text-change', function () {
            utils.delay(100, function () {
                var key = $el.getAttribute('data-key')
                var data = {}
                var path = $el.getAttribute('data-path')
                data[key] = editor.root.innerHTML
                renderSavingIndicator({hide: false, text: 'Saving...'})
                $.ajax({type: 'put', url: path, data: data})
                    .done(function () {
                        renderSavingIndicator({text: 'Saved'})
                        window.setTimeout(function () {
                            renderSavingIndicator({hide: true})
                        }, 500)
                    })
            })
        })
    }
}


var quill = function($el, options) {
    for (var i =0; i < $el.length; i++)
    {
        initializeQuill($el[i], options)
    }
}

module.exports = quill