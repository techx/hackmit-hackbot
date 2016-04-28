# Description:
#   Confessions!
#
# Configuration:
#   HUBOT_CONFESS_ROOM
#
# Commands:
#   hubot confess <confession> - submit anonymous confession (can be sent in a private message)
#
# Author:
#   anishathalye

translate = require('./translate')

module.exports = (robot) ->

	config = require('hubot-conf')('confess', robot)

	robot.respond /confess (.+)$/i, (msg) ->
		text = "[Confession] #{msg.match[1]}"
		room = config('room')
		robot.send {room: room}, text

  robot.respond /obfuscate confess (.+)$/i, (msg) ->
		text = "[Confession] #{msg.match[1]}"
		room = config('room')
		robot.send {room: room}, translate(text)
