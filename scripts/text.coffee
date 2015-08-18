# Description:
#   Text reciever
#
# Configuration:
#   HUBOT_TEXT_CHANNEL - channel to send messages in
#   HUBOT_TEXT_ACCOUNT - Account SID for verification
#
# Author:
#   Detry322

module.exports = (robot) ->

  config = require('hubot-conf')('text', robot)

  robot.router.post '/text/receive', (req, res) ->
    res.header('Content-Type','text/xml').send "<Response></Response>"
    number = req.body.From
    message = req.body.Body
    decorator = "Twilio"
    if req.body.AccountSid == config('account')
      matches = message.match(/(\+?[0-9]+) - (.+)$/)
      if matches?
        number = matches[1]
        message = matches[2]
        decorator = "Google Voice"
      robot.messageRoom config('channel'), "[#{decorator}] Text from #{number}: #{message}"
