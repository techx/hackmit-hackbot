# Description:
#   Quick test to see if hubot is alive.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Author:
#   Jack Serrino (Detry322)

module.exports = (robot) ->
  robot.router.get '/status/ping', (req, res) ->
    res.header('Content-Type','text/plain').send "Pong!"

