# Description:
#   Text reciever
#
# Configuration:
#   HUBOT_TEXT_CHANNEL - channel to send messages in
#   HUBOT_TEXT_ACCOUNT - Account SID for verification
#
# Author:
#   Detry322

https = require('https')

ERR_MSG = "Sorry, there was an error completing your request."

Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output

module.exports = (robot) ->

  config = require('hubot-conf')('text', robot)

  robot.router.post '/text/receive', (req, res) ->
    res.header('Content-Type','text/xml').send "<Response></Response>"
    number = req.body.From
    message = req.body.Body
    if req.body.AccountSid == config('account')
      robot.messageRoom config('channel'), "Text from #{number}: #{message}"
