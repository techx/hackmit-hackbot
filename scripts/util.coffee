# Description:
#   Utilities
#
# Author:
#   anishathalye


module.exports = (robot) ->

  config = require('hubot-conf')('util', robot)

  # a hacky way to override the shortcut prefix
  robot.hear /(.*)/, (res) ->
    prefix = config('shortcut.prefix')
    if prefix?
      text = res.match[1]
      matches = text.match(///^\s*#{prefix}([a-z]+)(\s+.*)?///)
      if matches?
        original = res.message.text
        args = matches[2] ? ''
        res.message.text = "!#{matches[1]}#{args}"
        robot.receive res.message
        res.message.text = original
