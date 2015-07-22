# Description:
#   Go link expander
#
# Commands:
#   None, auto expands go links of the form go/whatever
#
# Author:
#   Jack Serrino (Detry322)

module.exports = (robot) ->

  robot.hear /go\/([^ ]*)/i, (res) ->
    link = res.match[1]
    res.send ("Go link: https://go.hackmit.org/" + link)
