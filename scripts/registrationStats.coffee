# Description:
#   HackMIT registration statistics.
#
# Configuration:
#   HUBOT_HACKMIT_AUTH_TOKEN
#
# Commands:
#   hubot reg stats|summary - get HackMIT reg stats summary
#   hubot reg fetch - force a fetch of data from the server
#
# Author:
#   Detry322

timeago = require('timeago')

filter = (arr, func) ->
  filtered = []
  for item in arr
    if func item
      filtered.push item
  filtered

formatSummary = (data) ->
  """*=== Registration Stats ===*
  *Verified:* #{data.verified}
  *Submitted:* #{data.submitted} (_M: #{data.demo.gender.M} F: #{data.demo.gender.F} O: #{data.demo.gender.O} N: #{data.submitted - (data.demo.gender.M + data.demo.gender.F + data.demo.gender.O)}_)
  _#{Math.round(100 * (data.demo.gender.F + data.demo.gender.O) / data.submitted)}-#{Math.round(100 * (data.demo.gender.F + data.demo.gender.O) / (data.demo.gender.F + data.demo.gender.O + data.demo.gender.M))}%  non-male_
  *Confirmed:* #{data.confirmed} (_M: #{data.confirmedMale} F: #{data.confirmedFemale} O: #{data.confirmedOther} N: #{data.confirmedNone}_) (_MIT: #{data.confirmedMit} non-MIT: #{data.confirmed - data.confirmedMit} declined: #{data.declined}_)
  _F / (M + F) = #{Math.round(100 * data.confirmedFemale / (data.confirmedFemale + data.confirmedMale))}%_"""

module.exports = (robot) ->

  config = require('hubot-conf')('hackmit', robot)

  stats = { data: null, time: null }

  getStats = (res, callback) ->
    robot.http("https://my.hackmit.org/api/users/stats")
        .header('Accept', 'application/json')
        .header('x-access-token', config("auth.token"))
        .get() (err, httpResponse, body) ->
          if not err and httpResponse.statusCode is 200
            try
              data = JSON.parse body
              if stats.data == null
                try
                  robot.adapter.topic { room: config('stats.room', '#botspam') }, "Submitted: #{data.submitted}"
                catch err
                  # if room is set to some nonexistent room (to disable it)
                  console.error err
              stats.data = data
              stats.time = new Date(data.lastUpdated)
              if callback? and res?
                callback(res)
            catch error
              # cry
              console.log error

  setInterval(getStats, 3*60*1000)

  getStatsOrCache = (res, callback) ->
    if stats.data?
      callback(res)
    else
      getStats(res, callback)

  print = (res, text) ->
    delta = timeago stats.time
    message = "_Up to date as of " + delta + "._\n"
    message += text
    res.send message

  printSummary = (res) ->
    print(res, formatSummary(stats.data))

  robot.respond /reg fetch$/i, (res) ->
    getStats res, (res) ->
      res.send "Fetched new data!"

  robot.respond /reg stats$/i, (res) ->
    getStatsOrCache(res, printSummary)

  robot.respond /reg sum(mary)?$/i, (res) ->
    getStatsOrCache(res, printSummary)
