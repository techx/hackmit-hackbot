# Description:
#   Fun responses
#
# Author:
#   anishathalye

module.exports = (robot) ->

  fireballResponses = [
    'Under your couch',
    'In the middle of the Pacific ocean',
    'In Italy',
    'On the BART',
    'In Kimberli\'s supervisor\'s office',
    'Only Google knows...',
  ]

  robot.hear /where.*fireball/i, (res) ->
    res.send res.random fireballResponses
