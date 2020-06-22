// License: LGPL-3.0-or-later
var view = require("vvvview")
var savingIndicator = require('../../components/saving_indicator')
var savingState = {hide: true}
var renderSavingIndicator = view(savingIndicator, document.body, savingState)

var donate_button_markup = "<a class='button' target='_blank' href='" + location.origin + "/nonprofits/" + app.nonprofit_id + "/donate' "

if(app.nonprofit && app.nonprofit.brand_color)
    donate_button_markup += "style='background-color:" + app.nonprofit.brand_color + ";'>Donate</a>"
else
    donate_button_markup += ">Donate</a>"

var email_buttons = ["bold", "italic", "formatBlock", "align", "createLink",
    "insertImage", "insertUnorderedList", "insertOrderedList",
    "undo", "redo", "insert_donate_button", "insert_name", "insert_first_name", "html"]

var froala = function($el, options) {
    $el.editable({
        key: app.froala_key,
        placeholder: options.placeholder || 'Edit text here',
        buttons: options.email_buttons ? email_buttons : options.buttons ? options.buttons : ["bold", "italic", "formatBlock", "align", "createLink", "insertImage", "insertVideo", "insertUnorderedList", "insertOrderedList", "undo", "redo", "html"],
        inlineMode: false,
        beautifyCode: true,
        plainPaste: true,
        blockTags: {p: 'Normal', h5: "Heading", small: 'Caption'},
        allowedAttrs: ["accept","accept-charset","accesskey","action","align","alt","async","autocomplete","autofocus","autoplay","autosave","background","bgcolor","border","charset","cellpadding","cellspacing","checked","cite","class","color","cols","colspan","content","contenteditable","contextmenu","controls","coords","data","data-.*","datetime","default","defer","dir","dirname","disabled","download","draggable","dropzone","enctype","for","form","formaction","headers","height","hidden","high","href","hreflang","http-equiv","icon","id","ismap","itemprop","keytype","kind","label","lang","language","list","loop","low","max","maxlength","media","method","min","multiple", "muted", "name","novalidate","open","optimum","pattern","ping","placeholder","poster","preload","pubdate","radiogroup","readonly","rel","required","reversed","rows","rowspan","sandbox","scope","scoped","scrolling","seamless","selected","shape","size","sizes","span","src","srcdoc","srclang","srcset","start","step","summary","spellcheck","style","tabindex","target","title","type","translate","usemap","value","valign","width","wrap"],
        imageUploadURL: '/image_attachments.json',
        imageUploadParams: {
            authenticity_token: $("meta[name='csrf-token']").attr('content')
        },
        imageDeleteURL: '/image_attachments/remove.json',
        imageErrorCallback: function (d) {
        },
        afterRemoveImageCallback: function ($img) {
            this.options.imageDeleteParams = {src: $img.attr('src')};
            this.deleteImage($img);
        },
        customButtons: {
            format_code: {
                title: 'format code',
                icon: {
                    type: 'font',
                    value: 'fa fa-bolt'
                },
                callback: function () {
                    // used to show code snippets.
                    // takes selected text, including typed html tags
                    // and wraps each text line in a <div>
                    // and appends all of the <div>s into a <pre> tag
                    // and then replaces that selected text with the
                    // newly created <pre> tag

                    var lines_of_code = this.text().split("\n")
                    var pre = document.createElement('pre')
                    pre.className = 'codeText'

                    // created <div>s for each new line and appends them to <pre>
                    lines_of_code.map(function (line) {
                        var div = document.createElement('div')
                        div.appendChild(document.createTextNode(line))
                        pre.appendChild(div)
                    })

                    var selected_elements = this.getSelectionElements()
                    var first_selected_element = selected_elements[0]
                    var parent_node = document.getElementsByClassName('froala-element')[0]

                    // inserts pre before selection
                    parent_node.insertBefore(pre, first_selected_element)

                    // inserts <br>s before and after <pre>
                    parent_node.insertBefore(document.createElement('br'), pre)
                    parent_node.insertBefore(document.createElement('br'), pre.nextSibling)

                    // deletes selection
                    selected_elements.map(function (el) {
                        parent_node.removeChild(el)
                    })

                    this.saveUndoStep()
                }
            },
            insert_donate_button: {
                title: 'Donate Button',
                icon: {
                    type: 'font',
                    value: 'fa fa-heart'
                },
                callback: function () {
                    this.insertHTML(donate_button_markup)
                    this.saveUndoStep()
                },
                refresh: function () {
                }
            },
            insert_name: {
                title: 'Insert recipient name',
                icon: {
                    type: 'txt',
                    value: 'Full Name'
                },
                callback: function () {
                    this.insertHTML("{{NAME}}")
                    this.saveUndoStep()
                },
                refresh: function () {
                }
            },
            insert_first_name: {
                title: 'Insert first name',
                icon: {
                    type: 'txt',
                    value: 'First Name'
                },
                callback: function () {
                    this.insertHTML("{{FIRSTNAME}}")
                    this.saveUndoStep()
                },
                refresh: function () {
                }
            },
        },
      videoAllowedAttrs: ["src","width","height","frameborder","allowfullscreen","webkitallowfullscreen","mozallowfullscreen","href","target","id","controls","value","name", "autoplay", "loop", "muted"]
    })

    $('.froala-popup').parents('.froala-editor').css('z-index', 99999)

    if (!options.noUpdateOnChange) {
        $el.on('editable.contentChanged', function (e, editor) {
            utils.delay(100, function () {
                var key = $el.data('key')
                var data = {}
                var path = $el.data('path')
                data[key] = $el.find('.froala-element').html()
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

    if (options.sticky) {
        window.onload = function () {
            var makeEditorStick = require('../scroll_toggle_class')
            var id = $el.attr('id') ? '#' + $el.attr('id') : false
            var parent = id ? id : '.froala-box'
            var child = id ? id + ' .froala-editor' : '.froala-editor'
            makeEditorStick(child, 'is-stuck', parent)
            $(child).css('width', $(parent).width())
            $(window).resize(function () {
                $(child).css('width', $(parent).width())
            })
        }
    }
}

module.exports = froala;