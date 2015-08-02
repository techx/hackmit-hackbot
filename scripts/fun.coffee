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
    'In Tel Aviv',
    'Ishaan has it',
    'I think Kimberli spilled it on her laptop',
    'Here: go/fireball'
  ]

  robot.hear /where.*fireball/i, (res) ->
    res.send res.random fireballResponses
