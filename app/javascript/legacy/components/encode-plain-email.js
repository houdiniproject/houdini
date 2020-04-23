// License: LGPL-3.0-or-later
const b64 = require('./b64')

module.exports = o => {
  var header = [
    'MIME-Version: 1.0'
  , `From: ${o.from}`
  , `Reply-To: ${o.from}`
  , `To: ${o.to}`
  , `Subject: ${o.subject}`]

  if(o.cc)  header = header.concat(`Cc: ${o.cc.join(',')}`)
  if(o.bcc) header = header.concat(`Bcc: ${o.bcc.join(',')}`)
  
  var email = header.concat(['Content-Type: text/plain', '', o.body])
    .join('\r\n').trim()

  return b64.encode(email)
}

