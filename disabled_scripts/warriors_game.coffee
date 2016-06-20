# Description:
#   Warriors game score
#
# Author:
#   detry322

querystring = require 'querystring'

module.exports = (robot) ->

  config = require('hubot-conf')('util', robot)

  robot.respond /clear$/, (res) ->
    res.send ("." for n in [1..60]).join "\n"

  if robot.adapterName == "slack"
      robot.logger.info "Adapter is slack: will terminate on client close"
      robot.adapter.client.on 'close', () ->
        process.exit(0)
    else
      robot.logger.info "Adapter is not slack, will not terminate on client close"

  robot.respond /warriors score/i, (res) ->
    robot.http("http://espn.go.com/nba/bottomline/scores").get() (err, result, body) ->
      if err or result.statusCode isnt 200
        res.send "Had trouble getting the score :("
        return
      qs = querystring.parse(body)
      res.send qs.nba_s_left1
