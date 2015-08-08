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

  stats = { data: null, time: null }

  getStats = (callback, res) ->
    robot.http("https://my.hackmit.org/api/users/stats")
        .header('Accept', 'application/json')
        .header('x-access-token', config("auth.token"))
        .get() (err, httpResponse, body) ->
          if not err and httpResponse.statusCode is 200
            try
              data = JSON.parse body
              stats.time = new Date
              stats.data = data
              if callback? and res?
                callback(res)
            catch error
              # cry

  setInterval(getStats, 5*60*1000)

  getStatsOrCache = (callback, res) ->
    if stats.data?
      callback(res)
    else
      getStats(callback, res)

  printStats = (res) ->
    minutes = Math.round((new Date - stats.time)/60000)
    minutes = if minutes == 1 then "1 minute" else minutes + " minutes"
    message = "_Up to date as of " + minutes + " ago._\n"
    message += formatStats(stats.data)
    res.send message

  robot.respond /reg(istration)? stat(istic)?s force$/i, (res) ->
    getStats(printStats, res)

  robot.respond /reg(istration)? stat(istic)?s$/i, (res) ->
    getStatsOrCache(printStats, res)

