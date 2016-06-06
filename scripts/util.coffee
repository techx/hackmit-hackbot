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

  robot.respond /clear$/, (res) ->
    res.send ("." for n in [1..60]).join "\n"

  if robot.adapterName == "slack"
      robot.logger.info "Adapter is slack: will terminate on client close"
      robot.adapter.client.on 'close', () ->
        process.exit(0)
    else
      robot.logger.info "Adapter is not slack, will not terminate on client close"

  robot.respond /echo2 ((.*\s*)+)/i, (res) ->
    res.send res.match[1]
