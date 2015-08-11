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
  *Confirmation:* _S:_ #{data.submitted} | _A:_ #{data.admitted} | _C:_ #{data.confirmed} | _D:_ #{data.declined}
  *Men:* _XS:_ #{shirts.XS} | _S:_ #{shirts.S} | _M:_ #{shirts.M} | _L:_ #{shirts.L} | _XL:_ #{shirts.XL} | _XXL:_ #{shirts.XXL}
  *Women:* _XS:_ #{shirts.WXS} | _S:_ #{shirts.WS} | _M:_ #{shirts.WM} | _L:_ #{shirts.WL} | _XL:_ #{shirts.WXL} | _XXL:_ #{shirts.WXXL}
  *Hosting:* _Friday:_ #{data.hostNeededFri} | _Saturday:_ #{data.hostNeededSat}
  *Reimbursement:* #{data.reimbursementTotal} ($#{data.reimbursementTotal*200})
  *Hardware:* #{data.wantsHardware}"""

formatFood = (foodArr) ->
  message = "*===FOOD RESTRICTIONS===*\n"
  for food in foodArr
    message += "*#{food.name}:* #{food.count}\n"
  message

formatSchools = (schoolArr) ->
  message = "*===SCHOOL DATA===*\n"
  for school in schoolArr
    message += "*#{school.email}:* _S:_ #{school.stats.submitted} | _A:_ #{school.stats.admitted} | _C:_ #{school.stats.confirmed} | _D:_ #{school.stats.declined}\n"
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
      schools = schools.slice(0,max);
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

