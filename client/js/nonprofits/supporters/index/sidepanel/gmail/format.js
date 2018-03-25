// License: LGPL-3.0-or-later
const R = require('ramda')
const moment = require('moment')

const b64 = require('../../../../../components/b64')
const encode = require( '../../../../../components/encode-plain-email')

const format = {}

format.composeData = data => {
  const cleanArray = s => s.replace(/ /g, '').split(',')
  data.cc = data.cc   ? cleanArray(data.cc)  : false
  data.bcc = data.bcc ? cleanArray(data.bcc) : false
  return {'userId': 'me', 'resource': {'raw': encode(data)}}
}

format.replyData = data => {
  return {'userId': 'me', 'resource': {'raw': encode(data), 'threadId': data.threadId}}
}

format.saveData = (resp, formData) => {
  var data = R.omit(['cc', 'bcc'], formData)
  return R.merge(data, {
      supporter_id: appl.supporter_details.id
    , nonprofit_id: app.nonprofit_id
    , recipient_count: '1' 
    , gmail_thread_id: resp.threadId 
    }
  )
}

format.thread = r => {
  const value = (s, o) => {
    var obj = R.find(R.propEq('name', s), o)
    if (!obj) return false
    return obj.value
  }

  const cleanReply = s => {
    // remove all the replies within the message
    var reply = R.take(1, s.split(/\n> /)).join('\n').trim()
    // remove signature
    return R.dropLast(1, reply.split(/\n/)).join('\n').trim()
  }

  var firstHeader = r.messages[0].payload.headers

  var from = value('From', firstHeader)

  var thread = {subject: value('Subject', firstHeader)}

  thread.messages = R.map(m => {
    var headers = m.payload.headers
    return {
      from:  value('From', headers)
    , to:    value('To', headers)
    , cc:    value('Cc', headers)
    , bcc:   value('Bcc', headers)
    , date:  moment(value('Date', headers)).format("ddd, M/D/YYYY, h:mmA")
    , body:  m.payload.parts
      ? cleanReply(b64.decode(R.find(R.propEq('mimeType', 'text/plain'), m.payload.parts).body.data))
      : b64.decode(m.payload.body.data)
    }
  }, r.messages)

  return thread
}

module.exports = format

