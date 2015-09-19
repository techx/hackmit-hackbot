# Description:
#   HackMIT registration statistics.
#
# Configuration:
#   HUBOT_HACKMIT_AUTH_TOKEN
#
# Commands:
#   hubot reg stats|summary - get HackMIT reg stats summary
#   hubot reg food - get HackMIT food restrictions stats
#   hubot reg schools - get top 15 schools stats
#   hubot reg school <regex> - get stats for all schools matching <regex>
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
  shirts = data.shirtSizes
  """*===SUMMARY===*
  *Hosting:* _Friday:_ #{data.hostNeededFri} | _Saturday:_ #{data.hostNeededSat} | _Total Unique:_ #{data.hostNeededUnique}
  *Hosting by Gender:* _F:_ #{data.hostNeededFemale} | _M:_ #{data.hostNeededMale} | _O:_ #{data.hostNeededOther} | _N:_ #{data.hostNeededNone}
  *Reimbursement:* #{data.reimbursementTotal} ($#{data.reimbursementTotal*200})
  *Hardware:* #{data.wantsHardware}
  *Checked in:* #{data.checkedIn}"""

formatFood = (foodArr) ->
  message = "*===FOOD RESTRICTIONS===*\n"
  for food in foodArr
    message += "*#{food.name}:* #{food.count}\n"
  message

formatSchools = (schoolArr) ->
  message = "*===SCHOOL DATA===*\n"
  submitted = 0
  admitted = 0
  confirmed = 0
  declined = 0
  for school in schoolArr
    submitted += school.stats.submitted
    admitted += school.stats.admitted
    confirmed += school.stats.confirmed
    declined += school.stats.declined
    message += "#{school.email} -- _S:_ #{school.stats.submitted} | _A:_ #{school.stats.admitted} | _C:_ #{school.stats.confirmed} | _D:_ #{school.stats.declined}\n"
  message += "Total: -- _S:_ #{submitted} | _A:_ #{admitted} | _C:_ #{confirmed} | _D:_ #{declined}\n"
  message


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
              if stats.data.checkedIn != data.checkedIn:
                robot.adapter.topic { room: '#botspam') }, "Checked in: #{stats.data.checkedIn}"
              stats.data = data
              stats.time = new Date(data.lastUpdated)
              if callback? and res?
                callback(res)
            catch error
              # cry

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

  printSchoolData = (search, max) ->
    return (res) ->
      schools = filter stats.data.demo.schools, (school) ->
        school.stats.submitted > 0 and school.email.match search
      schools.sort (a,b) ->
        b.count - a.count
      schools = schools.slice(0,max)
      print(res, formatSchools(schools))

  printFood = (res) ->
    print(res, formatFood(stats.data.dietaryRestrictions))

  robot.respond /reg fetch$/i, (res) ->
    getStats res, (res) ->
      res.send "Fetched new data!"

  robot.respond /reg stats$/i, (res) ->
    getStatsOrCache(res, printSummary)

  robot.respond /reg sum(mary)?$/i, (res) ->
    getStatsOrCache(res, printSummary)

  robot.respond /reg schools$/i, (res) ->
    getStatsOrCache(res, printSchoolData("", 10))

  robot.respond /reg schools? (.*)/i, (res) ->
    search = res.match[1]
    getStatsOrCache(res, printSchoolData(search, Infinity))

  robot.respond /reg food$/i, (res) ->
    getStatsOrCache(res, printFood)

