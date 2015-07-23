# Description:
#   Go link expander
#
# Author:
#   Jack Serrino (Detry322)

module.exports = (robot) ->

  robot.hear /(^| )go\/([^ \n]+)/i, (res) ->
    link = res.match[2]
    res.send ("Go link: https://go.hackmit.org/" + link)
