# Description:
#   Go link expander
#
# Author:
#   Jack Serrino (Detry322)

module.exports = (robot) ->

  robot.hear /go\/([^ ]*)/i, (res) ->
    link = res.match[1]
    res.send ("Go link: https://go.hackmit.org/" + link)
