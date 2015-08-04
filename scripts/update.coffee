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

restart = (msg) ->
  msg.send "Restarting..."
  setTimeout () ->
    process.exit()
  , 500 # Give process some time to send message

module.exports = (robot) ->

  robot.respond /update( yourself)?$/i, (msg) ->
    changes = false
    try
      msg.send "git pull..."
      child_process.exec 'git fetch && git reset --hard origin/master', (error, stdout, stderr) ->
        if error
          msg.send "git pull failed: ```" + stderr + "```"
        else
          output = stdout+''
          if not /Already up\-to\-date/.test output
            msg.send "my source code changed:\n```" + output + "```"
            changes = true
          else
            msg.send "my source code is up-to-date"
        try
          msg.send "npm update..."
          child_process.exec 'npm update', (error, stdout, stderr) ->
            if error
              msg.send "npm update failed: ```" + stderr + "```"
            else
              output = stdout+''
              if /node_modules/.test output
                msg.send "some dependencies updated:\n```" + output + "```"
                changes = true
              else
                msg.send "all dependencies are up-to-date"
            if changes
              downloaded_updates = true
              restart msg
            else
              if downloaded_updates
                restart msg
              else
                msg.send "I'm up-to-date!"
        catch error
          msg.send "npm update failed: " + error
    catch error
      msg.send "git pull failed: " + error
