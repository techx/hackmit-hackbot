# Description:
#   Text reciever
#
# Configuration:
#   HUBOT_TEXT_CHANNEL - channel to send messages in
#   HUBOT_TEXT_ACCOUNT - Account SID for verification
#
# Commands:
#   hubot text add <number> <name> - add a number to the list (make sure to add the +)
#   hubot text numberof <name> - gets the number of the name
#   hubot text whois <number> - gets the name of the person with that number
#   hubot text remove <number>
#
# Author:
#   Detry322

BRAIN_LOCATION = 'text.numbers'

module.exports = (robot) ->

  config = require('hubot-conf')('text', robot)

  addNumber = (number, name) ->
    mapping = robot.brain.get(BRAIN_LOCATION) or {}
    mapping[number] = name
    robot.brain.set BRAIN_LOCATION, mapping

  removeNumber = (number) ->
    mapping = robot.brain.get(BRAIN_LOCATION) or {}
    delete mapping["number"]
    robot.brain.set BRAIN_LOCATION, mapping

  getName = (number) ->
    mapping = robot.brain.get(BRAIN_LOCATION) or {}
    mapping[number]

  getNumber = (name) ->
    mapping = robot.brain.get(BRAIN_LOCATION) or {}
    for number, value of mapping
      if value == name
        return number
    undefined

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
      name = if getName(number) then getName(number) else number
      robot.messageRoom config('channel'), "[#{decorator}] Text from #{name}: #{message}"

  robot.respond /text add (\+?[0-9]+) (.+)$/i, (res) ->
    number = res.match[1]
    name = res.match[2]
    addNumber(number, name)
    res.send "Added: `#{number}` for `#{name}`"

  robot.respond /text numberof (.+)$/i, (res) ->
    name = res.match[1]
    number = getNumber(name)
    if number
      res.send "`#{name}` is `#{number}`"
    else
      res.send "Could not find number for `#{name}`"

  robot.respond /text whois (\+?[0-9]+)$/i, (res) ->
    number = res.match[1]
    name = getName(number)
    if name
      res.send "`#{number}` is `#{name}`"
    else
      res.send "Could not find name for `#{number}`"

  robot.respond /text remove (\+?[0-9]+)$/i, (res) ->
    number = res.match[1]
    removeNumber(number)
    res.send "Removed: `#{number}`"
