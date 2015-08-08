# Description:
#   HackMIT registration statistics.
#
# Configuration:
#   HUBOT_HACKMIT_AUTH_TOKEN
#
# Commands:
#   hubot reg stats - get HackMIT registration statistics
#
# Author:
#   Detry322

util = require('util')

formatStats = (data) ->
  sb = data.submitted
  a = data.admitted
  c = data.confirmed
  d = data.declined
  shirts = data.shirtSizes
  xs = shirts.XS
  s = shirts.S
  m = shirts.M
  l = shirts.L
  xl = shirts.XL
  xxl = shirts.XXL
  wxs = shirts.WXS
  ws = shirts.WS
  wm = shirts.WM
  wl = shirts.WL
  wxl = shirts.WXL
  wxxl = shirts.WXXL
  t = data.reimbursementTotal
  h = data.wantsHardware
  util.format("*Status*\n_Submitted:_ %d\n_Admitted:_ %d\n_Confirmed:_ %d\n_Declined:_ %d\n=============================\n*Men's Shirts:*\n_XS:_ %d | _S:_ %d | _M:_ %d | _L:_ %d | _XL:_ %d | _XXL:_ %d\n*Women's Shirts*\n_XS:_ %d | _S:_ %d | _M:_ %d | _L:_ %d | _XL:_ %d | _XXL:_ %d\n=============================\n*Other*\n_Needs reimbursement:_ %d\n_Reimbursement cost:_ $%d (Assuming $200 per person)\n_Wants hardware:_ %d", sb, a, c, d, xs, s, m, l, xl, xxl, wxs, ws, wm, wl, wxl, wxxl, t, t*200, h)

module.exports = (robot) ->

  config = require('hubot-conf')('hackmit', robot)

  getStats = (res, callback) ->
    res.http("https://my.hackmit.org/api/users/stats")
        .header('Accept', 'application/json')
        .header('x-access-token', config("auth.token"))
        .get() (err, httpResponse, body) ->
          if err
            res.send "Could not fetch stats (error in http) :("
          else if httpResponse.statusCode isnt 200
            res.send "Could not fetch stats (status wasn't 200) :("
          else
            try
              data = JSON.parse body
              robot.brain.set 'hackmit.regstats.time', new Date
              robot.brain.set 'hackmit.regstats.data', data
              callback(res, data, false)
            catch error
              res.send "Could not fetch stats (error parsing JSON) :("

  getStatsOrCache = (res, callback) ->
    time = robot.brain.get('hackmit.regstats.time') or 0
    if (new Date) - time > 30*60*1000
      getStats(res, callback)
    else
      data = robot.brain.get('hackmit.regstats.data')
      callback(res, data, true)

  printStats = (res, data, cache) ->
    message = if cache then "_Using cache._ Use `hackbot reg stats force` for forced update.\n" else ""
    message += formatStats(data)
    res.send message

  robot.respond /reg(istration)? stat(istic)?s force$/i, (res) ->
    getStats(res, printStats)

  robot.respond /reg(istration)? stat(istic)?s$/i, (res) ->
    getStatsOrCache(res, printStats)

