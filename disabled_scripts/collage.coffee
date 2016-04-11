# Description:
#   Collage status.
#
# Configuration:
#   HUBOT_COLLAGE_PATH
#   HUBOT_COLLAGE_USERNAME
#   HUBOT_COLLAGE_PASSWORD
#
# Commands:
#   hubot collage - display collage status.
#
# Author:
#   anishathalye

https = require('https')

ERR_MSG = "Sorry, there was an error completing your request."

Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output

module.exports = (robot) ->

  config = require('hubot-conf')('collage', robot)

  sendStatus = (msg) ->
    username = config 'username'
    password = config 'password'
    auth = 'Basic ' + new Buffer(username + ':' + password).toString('base64')
    headers = {'Host': 'collage.hackmit.org', 'Authorization': auth}
    options =
      host: 'collage.hackmit.org',
      path: config('path'),
      headers: headers
    try
      https.get options, (res) ->
        body = ''
        res.on 'data', (chunk) ->
          body += chunk
        res.on 'end', () ->
          arr = JSON.parse body
          msg.send "#{arr.unique().length} unique submissions"
        res.on 'error', (er) ->
          msg.send ERR_MSG
    catch err
      msg.send ERR_MSG

  robot.respond /collage\s*$/i, (res) ->
    sendStatus res
