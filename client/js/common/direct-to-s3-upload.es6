// License: LGPL-3.0-or-later
const flyd = require('flyd')
const R = require('ramda')


// local
const request = require('./super-agent-frp')
const postFormData = require('./post-form-data')


// Pass in a stream of Input Nodes with type file
// Make a post request to our server to start the import
// Will create a backgrounded job and email the user when 
// completed
// Returns a stream of {uri: 'uri of uploaded file on s3', formData: 'original form data'}
const uploadFile = R.curry(input => {
  // We need to get an AWS presigned post thing to so we can upload files
  // Stream of pairs of [formObjData, presignedPostObj]
  var withPresignedPost$ = flyd.map(
    resp => [input, resp.body]
  , request.post('/aws_presigned_posts').perform()
  )

  // Stream of upload responses from s3
  return flyd.flatMap(
    pair => {
      var [input, presignedPost] = pair
      var url = `${presignedPost.s3_direct_url}`
      var file = input.files[0]
      var fileUrl = `${url}/tmp/${presignedPost.s3_uuid}/${file.name}`
      var payload = R.merge(JSON.parse(presignedPost.s3_presigned_post), {file})

      return flyd.map(resp => ({uri: fileUrl, file}), postFormData(url, payload))
    }
  , withPresignedPost$)
})


module.exports = uploadFile

