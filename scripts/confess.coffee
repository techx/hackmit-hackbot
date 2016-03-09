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
    user = res.message.user
    ONE_HOUR = 1000*60*60
    if (not user.confess_id? or (new Date() - user.confess_id_creation) > ONE_HOUR {
      user.confess_id = Math.floor(Math.random()*100000000)
      user.confess_id_creation = new Date()
    }
    text = "[Confession: #{user.confess_id}] #{msg.match[1]}"
    room = config('room')
    robot.send {room: room}, text
