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
  femAndOther = data.confirmedFemale + data.confirmedOther
  # If every N applicant was male
  minMale = Math.round(100 * femAndOther / data.confirmed)
  # Not considering N applicants
  maxMale = Math.round(100 * femAndOther / (femAndOther + data.confirmedMale))
  nonMale = if minMale isnt maxMale then minMale + '-' + maxMale else minMale

  mit = Math.round(100 * data.confirmedMit / data.confirmed)
  red = Math.round(100 * data.teamRed / data.confirmed)
  blue = Math.round(100 * data.teamBlue / data.confirmed)

  """*=== Registration Stats ===*
  *Confirmed:* #{data.confirmed} (_#{Math.round(100 * data.confirmed / data.admitted)}%_)
  _#{nonMale}% non-male_, _#{mit}% MIT_
  _#{blue}%_ :blue_heart: :heart: _#{red}%_"""

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
