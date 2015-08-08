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

module.exports = (robot) ->

  config = require('hubot-conf')('hackmit', robot)

  robot.respond /reg(istration)? stat(istic)?s$/i, (res) ->
    res.http("https://my.hackmit.org/api/users/stats")
      .header('Accept', 'application/json')
      .header('x-access-token', config("auth.token"))
      .get() (err, httpResponse, body) ->
        if err
          res.send "Could not fetch stats (error in http) :("
          return
        if httpResponse.statusCode isnt 200
          res.send "Could not fetch stats (status wasn't 200) :("
          return
        try
          data = JSON.parse body
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
          message = util.format("_*Status*_\n*Submitted:* %d\n*Admitted:* %d\n*Confirmed:* %d\n*Declined:* %d\n=============================\n_*Shirts*_\n*Men:*\n*XS:* %d | *S:* %d | *M:* %d | *L:* %d | *XL:* %d | *XXL:* %d\n*Women*\n*XS:* %d | *S:* %d | *M:* %d | *L:* %d | *XL:* %d | *XXL:* %d\n=============================\n_*Other*_\n*Needs reimbursement:* %d\n*Reimbursement cost:* $%d (Assuming $200 per person)\n*Wants hardware:* %d", sb, a, c, d, xs, s, m, l, xl, xxl, wxs, ws, wm, wl, wxl, wxxl, t, t*200, h)
          res.send message
        catch error
          res.send "Could not fetch stats (error parsing JSON) :("
