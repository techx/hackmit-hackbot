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

  lennySnakeParts = [
    "╚═( ͡° ͜ʖ ͡°)═╝",
    "╚═(███)═╝",
    "╚═(███)═╝",
    ".╚═(███)═╝",
    "..╚═(███)═╝",
    "…╚═(███)═╝",
    "…╚═(███)═╝",
    "..╚═(███)═╝",
    ".╚═(███)═╝",
    "╚═(███)═╝",
    ".╚═(███)═╝",
    "..╚═(███)═╝",
    "…╚═(███)═╝",
    "…╚═(███)═╝",
    "…..╚(███)╝",
    "……╚(██)╝",
    "………(█)",
    "……….*"
  ]

  lennySnakeTick = 300 # milliseconds

  robot.hear /lennysnake/i, (res) ->
    sendFrom = (i) ->
      if i < lennySnakeParts.length
        res.send lennySnakeParts[i]
        setTimeout sendFrom, lennySnakeTick, i + 1
    sendFrom 0

  robot.hear /jason/i, (res) ->
    # make this less spammy
    if Math.random() < 0.2
      res.send "but he's not course 6"

  dootDoot = """```
thank mr skeltal

░░░░░░░░░░░▐▄▐
░░░░░░▄▄▄░░▄██▄
░░░░░▐▀█▀▌░░░░▀█▄
░░░░░▐█▄█▌░░░░░░▀█▄
░░░░░░▀▄▀░░░▄▄▄▄▄▀▀
░░░░▄▄▄██▀▀▀▀
░░░█▀▄▄▄█░▀▀
░░░▌░▄▄▄▐▌▀▀▀
▄░▐░░░▄▄░█░▀▀
▀█▌░░░▄░▀█▀░▀
░░░░░░░▄▄▐▌▄▄
░░░░░░░▀███▀█░▄
░░░░░░▐▌▀▄▀▄▀▐▄
░░░░░░▐▀░░░░░░▐▌
░░░░░░█░░░░░░░░█
░░░░░▐▌░░░░░░░░░█
░░░░░█░░░░░░░░░░▐▌
```"""

  robot.hear /(dootdootdoot|[0-9]spooky)/i, (res) ->
    res.send dootDoot

  robot.hear /ay+ l[mfao]+/i, (res) ->
    res.send ':alien: ayy lmao :alien:'


  troll = [
    "*Stef*: im in that class too",
    "*Stef*: mg me too",
    "*Stef*: ????? :chicken: :chicken: :chicken:",
    "*Stef*: I failed",
    "*Stef*: :pineapple: :pineapple: :pineapple:",
    "*Stef*: o rite jk I have to do 7.012 pset",
    "*Stef*: totally agree!!",
    "*Stef*: it's cuz I just add dropped",
    "*Stef*: I can prove it rigorously",
    "*Stef*: wtf I'm in this group",
    "*Stef*: I luv genetics"
  ]

  robot.hear /stef.*troll/, (res) ->
    res.send res.random troll
