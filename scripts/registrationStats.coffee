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
          p = (n, d) -> (n/d*100).toFixed(2) + "%"
          data = JSON.parse body
          total = data.total
          verified = data.verified
          submitted = data.submitted
          male = data.demo.gender.M
          female = data.demo.gender.F
          other = data.demo.gender.O
          nr = data.demo.gender.N
          schools = data.demo.schools.sort((a,b) -> b.count - a.count)
          message = util.format("Total Users: %d\nVerified Users: %d (%s)\nSubmitted Users: %d (%s)\n===============================\nMale: %d (%s)\nFemale: %d (%s)\nOther: %d (%s)\nNo Response: %d (%s)\n===============================\nTop 5 schools:\n1. %s (%d)\n2. %s (%d)\n3. %s (%d)\n4. %s (%d)\n5. %s (%d)",total, verified, p(verified, total), submitted, p(submitted, total), male, p(male, total), female, p(female, total), other, p(other, total), nr, p(nr, total), schools[0].email, schools[0].count, schools[1].email, schools[1].count, schools[2].email, schools[2].count, schools[3].email, schools[3].count, schools[4].email, schools[4].count)
          res.send message
        catch error
          res.send "Could not fetch stats (error parsing JSON) :("
