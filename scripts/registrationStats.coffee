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

token = process.env.HUBOT_HACKMIT_AUTH_TOKEN
unless token?
  console.log "Missing HUBOT_HACKMIT_AUTH_TOKEN, please set and try again"
  process.exit(1)

module.exports = (robot) ->

  robot.respond /reg(istration)? stat(istic)?s$/i, (res) ->
    res.http("https://my.hackmit.org/api/users/stats")
      .header('Accept', 'application/json')
      .header('x-access-token', token)
      .get() (err, httpResponse, body) ->
        if err
          res.send "Could not fetch stats (error in http) :("
          return
        if httpResponse.statusCode isnt 200
          res.send "Could not fetch stats (status wasn't 200) :("
          return
        try
          data = JSON.parse body
          submitted = data.submitted
          admitted = data.admitted
          confirmed = data.confirmed
          declined = data.declined
          none = data.shirtSizes.None
          xsmall = data.shirtSizes.XS
          small = data.shirtSizes.S
          medium = data.shirtSizes.M
          large = data.shirtSizes.L
          xlarge = data.shirtSizes.XL
          xxlarge = data.shirtSizes.XXL
          message = util.format("*Status*\nSubmitted: %d\nAdmitted: %d\nConfirmed: %d\nDeclined: %d\n===============================\n*Reimbursements*\nTotal: %d\nMissing: %d\n===============================\n*Shirts*\nNone: %d\nX Small: %d\nSmall: %d\nMedium: %d\nLarge: %d\nX Large: %d\nXX Large: %d", submitted, admitted, confirmed, declined, none, xsmall, small, medium, large, xlarge, xxlarge)
          res.send message
        catch error
          res.send "Could not fetch stats (error parsing JSON) :("
