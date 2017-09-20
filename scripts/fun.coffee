# Description:
#   Fun responses
#
# Author:
#   anishathalye

module.exports = (robot) ->

  robot.hear /\s?#dev\b/, (res) ->
    res.send 'Did you mean #anish-talks-into-void?'

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

  robot.hear /lenny(snake|pede)/i, (res) ->
    sendFrom = (i) ->
      if i < lennySnakeParts.length
        res.send lennySnakeParts[i]
        setTimeout sendFrom, lennySnakeTick, i + 1
    sendFrom 0

  robot.hear /jason/i, (res) ->
    # make this less spammy
    if Math.random() < 0.2
      robot.emit 'slack.reaction',
        message: res.message
        name: 'upvote'

  robot.hear /michael/i, (res) ->
    # make this less spammy
    if Math.random() < 0.05
      robot.emit 'slack.reaction',
        message: res.message
        name: 'silverman'

  # match basically any 100-char-long english sentence
  robot.hear /e/i, (res) ->
    # make this less spammy
    if res.message.text.length > 100 && Math.random() < 0.001
      res.send "whoa whoa guys are we sure that's a good idea?"

  robot.hear /work/i, (res) ->
    if res.message.text.length > 50 && Math.random() < 0.1
      res.send "It's not work it's Datto"

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

  robot.hear /(^|\b)a+y+ l[mfao]+($|\b)/i, (res) ->
    res.send ':alien: ayy lmao :alien:'


  troll = [
    "*Stef*: im in that class too",
    "*Stef*: omg me too",
    "*Stef*: ????? :chicken: :chicken: :chicken:",
    "*Stef*: I failed",
    "*Stef*: :pineapple: :pineapple: :pineapple:",
    "*Stef*: o rite jk I have to do 7.012 pset",
    "*Stef*: totally agree!!",
    "*Stef*: it's cuz I just add dropped",
    "*Stef*: I can prove it rigorously",
    "*Stef*: wtf I'm in this group",
    "*Stef*: I luv genetics",
    "*Stef*: wtf that's what I was gonna say"
  ]

  robot.hear /stef.*troll/i, (res) ->
    res.send res.random troll

  more_troll = [
    "*Logan*: allllllllll right",
    "*Logan*: look who decided to show up",
    "*Logan*: big bois",
    "*Logan*: that's bananas",
    "*Logan*: it's lit",
    "*Logan*: not like this",
    "*Logan*: that's fucked",
    "*Logan*: eecs eecs eecs eecs",
    "*Logan*: you dog",
    "*Logan*: that's pretty soft",
  ]

  robot.hear /logan.*troll/i, (res) ->
    res.send res.random more_troll

  pusheens = [
    "http://i.imgur.com/ozA8GSu.png",
    "http://i.imgur.com/ZKQc2Zr.png",
    "http://i.imgur.com/4kYoLqW.png",
    "http://i.imgur.com/RrLH94y.png",
    "http://i.imgur.com/frlzb8j.png",
    "http://i.imgur.com/CrlTN9g.png",
    "http://i.imgur.com/T3aU0jE.png",
    "http://i.imgur.com/WVNB0AI.png",
    "http://i.imgur.com/MgURast.png",
    "http://i.imgur.com/h0WeeGt.png",
    "http://i.imgur.com/5Gaquu2.png",
    "http://i.imgur.com/KBRkat2.png",
    "http://i.imgur.com/2DA3pUj.png",
    "http://i.imgur.com/zbkwKyo.png",
    "http://i.imgur.com/ZjxGDGu.png",
    "http://i.imgur.com/2fM3Llu.png",
    "http://i.imgur.com/vmBTVZT.png",
    "http://i.imgur.com/LM4RhiD.png",
    "http://i.imgur.com/GsA3vF8.png",
    "http://i.imgur.com/SRlVsQl.png",
  ]

  robot.hear /pusheen/i, (res) ->
    res.send res.random pusheens

  robot.hear /kim.*mom/i, (res) ->
    res.send 'https://answers.yahoo.com/question/index?qid=20100404125550AARFOJe'

  robot.hear /stef/i, (res) ->
    if Math.random() < 0.01
      res.send res.random troll

  robot.hear /logan/i, (res) ->
    if Math.random() < 0.01
      res.send res.random more_troll

  robot.hear /\btfti\b/, (res) ->
    if Math.random() < 0.2
      res.send 'tfti'

  robot.hear /^same$/, (res) ->
    if Math.random() < 0.4
      res.send 'same'

  robot.respond /correct (.*)/, (res) ->
    msg = res.match[1]
    res.send msg.replace(/[aeiou]/ig,'')

  selfDestructSequence = [
    "Initiating HackMIT self-destruct sequence...",
    "10: Leaking sponsorship info...",
    "9: Insulting all previous company contacts...",
    "8: Transferring funds to FCF...",
    "7",
    "6: Destroying all AWS instances...",
    "5: ",
    "4: Petting Oscar...",
    "3",
    "2",
    "1: You've met with a terrible fate, haven't you?",
    "http://rs651.pbsrc.com/albums/uu236/416o/explosion.gif~c200"
  ]

  selfDestructTick = 1000 #milliseconds

  robot.respond /selfdestruct/i, (res) ->
    sendFrom = (i) ->
      if i < selfDestructSequence.length
        res.send selfDestructSequence[i]
        setTimeout sendFrom, selfDestructTick, i + 1
    sendFrom 0

  # robot.hear /retreat/i, (res) ->
  #   res.send 'Did you mean: *kickoff*?'
