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

module.exports = (robot) ->

	config = require('hubot-conf')('confess', robot)

	robot.respond /confess (.+)$/i, (msg) ->
		text = "[Confession] #{msg.match[1]}"
		room = config('room')
		robot.send {room: room}, text
		msg.send "Posted in #{room}!"
