# Description:
#   Utilities
#
# Author:
#   anishathalye

shallowClone = (obj) ->
  copy = {}
  for own key, value of obj
    copy[key] = value
  copy.__proto__ = obj.__proto__ # not standard in ECMAScript, but it works
  return copy

module.exports = (robot) ->

  config = require('hubot-conf')('util', robot)

  # a hacky way to override the shortcut prefix
  robot.hear /(.*)/, (res) ->
    prefix = config('shortcut.prefix')
    if prefix?
      text = res.match[1]
      matches = text.match(///^\s*#{prefix}([a-z]+)(\s+.*)?///)
      if matches?
        args = matches[2] ? ''
        msg = shallowClone(res.message)
        msg.text = "!#{matches[1]}#{args}"
        robot.receive msg

  robot.respond /clear$/, (res) ->
    res.send ("." for n in [1..60]).join "\n"
