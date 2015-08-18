# Description:
#   Allows hubot to update itself using git pull and npm update.
#   If updates are downloaded you'll need to restart hubot, for example using "hubot die" (restart using a watcher like forever.js).
#
#   Shamelessly stolen from: https://github.com/github/hubot-scripts/blob/master/src/scripts/update.coffee
#   ... with some slight modifications.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot update - Performs a git pull and npm update.
#
# Author:
#   benjamine, Detry322

child_process = require 'child_process'
downloaded_updates = false

restart = (res) ->
  res.send "Restarting..."
  setTimeout () ->
    process.exit()
  , 500 # Give process some time to send message

send = (res, should_send, message) ->
  if should_send
    res.send message

update = (res, send_std, send_err) ->
  try
    send res, send_std, "fetching latest source code..."
    child_process.exec 'git fetch --all >/dev/null 2>&1 && git log --oneline --graph --stat HEAD..@{u} && git reset --hard @{u}', (error, stdout, stderr) ->
      if error
        send res, send_err, "git fetch/reset failed: ```" + stderr + "```"
      else
        send res, send_std, "```#{stdout}```"
      try
        send res, send_std, "npm update..."
        child_process.exec 'npm update', (error, stdout, stderr) ->
          if error
            send res, send_err, "npm update failed: ```" + stderr + "```"
          else
            output = stdout+''
            if /node_modules/.test output
              send res, send_std, "some dependencies updated:\n```" + output + "```"
            else
              send res, send_std, "all dependencies are up-to-date"
          restart res
      catch error
        send res, send_err, "npm update failed: " + error
  catch error
    send res, send_err, "git pull failed: " + error

module.exports = (robot) ->

  robot.respond /restart( yourself)?$/i, (res) ->
    restart res

  robot.respond /update silent$/i, (res) ->
    res.send "Updating..."
    update res, false, true

  robot.respond /update super silent$/i, (res) ->
    update res, false, false

  robot.respond /update( yourself)?$/i, (res) ->
    update res, true, true
