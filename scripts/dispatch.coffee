# Description:
#   Dispatch interaction.
#
# Configuration:
#   HUBOT_DISPATCH_URL - api endpoint
#
# Commands:
#   hubot dispatch <N> from <channels> for <description> - create a task
#   hubot dispatch status - dispatch status
#
# Author:
#   anishathalye

timeago = require('timeago')

ERR_MSG = "Sorry, there was an error completing your request."

module.exports = (robot) ->

  config = require('hubot-conf')('dispatch', robot)

  robot.respond /dispatch\s+status/i, (res) ->
    robot.http(config('url')).get() (err, httpRes, body) ->
      if err
        res.send ERR_MSG
      else
        body = JSON.parse(body)
        response = ["Tasks:"]
        for task in body.tasks
          msg = "*#{task.code}* - _#{timeago(task.created)}_ - #{task.description} (#{task.workers.length}/#{task.max})"
          response.push msg
        res.send response.join '\n'

  robot.respond /dispatch\s+(\d+)\s+from\s+(#[a-z]+(?:\s+#[a-z]+)*)\s+for\s+(.*)/i, (res) ->
    count = parseInt(res.match[1])
    channels = res.match[2]
    description = res.match[3]
    channels = (ch.substring(1) for ch in channels.split(/\s+/))
    robot.http(config('url')).header('Content-Type', 'application/json')
      .post(JSON.stringify({"call": "create", "arguments": {
        "min": count, "max": count,
        "description": description,
        "channelNames": channels
      }})) (err, httpRes, body) ->
        if err
          res.send ERR_MSG
        else
          body = JSON.parse(body)
          if body.channels.length > 0
            ch = ("##{n}" for n in body.channels)
            res.send "Created task #{body.code} for #{ch.join ', '}"
          else
            res.send "Didn't match any channels!"
