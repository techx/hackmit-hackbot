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

  sendStatus = (url, res) ->
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
          res.send "#{arr.unique().length} unique submissions"
        res.on 'error', (er) ->
          res.send ERR_MSG
    catch err
      res.send ERR_MSG

  robot.respond /collage\s*$/i, (res) ->
    formatMeta (msg) ->
      res.send msg

  robot.respond /status\s*$/i, (res) ->
    getStatuses (statuses, err) ->
      if err
        res.send ERR_MSG
      else
        res.send formatStatuses(statuses)
        formatMeta (msg) ->
          res.send msg

  robot.respond /status (.*)/i, (res) ->
    search = res.match[1]
    getStatuses (statuses, err) ->
      if err
        res.send "Sorry, there was an error completing your request."
      else
        filtered = filter statuses, (status) ->
          status.name.match search
        if filtered.length > 0
          res.send formatStatuses(filtered)
        else
          res.send "Sorry, there were no results matching `#{search}`. Perhaps tweak your regex?"
