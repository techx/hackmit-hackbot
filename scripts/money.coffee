# Description:
#   HackMIT sponsorship money
#
# Commands:
#   hubot money / hubot $ - get how much money we have collected
#
# Author:
#   katexyu

util = require('util')
Spreadsheet = require("google-spreadsheet")

creds = require('../hackmit-money-2015-credentials.json')

formatMessage = (money) ->
  received = money.received
  outstanding = money.outstanding
  total = money.total
  "*Received:* $#{received}K\n*Outstanding:* $#{outstanding}K\n*Total:* $#{total}K"

formatTopic = (money) ->
  formatMessage(money).replace(/\n/g,' ')

makeMoney = (received, outstanding) -> #AYY MAKE MONEY
  {
    received: received,
    outstanding: outstanding,
    total: received + outstanding
  }

makeError = (message, err) ->
  {
    message: message,
    err: err
  }

module.exports = (robot) ->
  config = require('hubot-conf')('money', robot)

  getMoney = (callback) ->
    moneyRow = parseInt(config 'row')
    receivedCol = parseInt(config 'received.col')
    outstandingCol = parseInt(config 'outstanding.col')
    spreadsheetUrl = config 'spreadsheet.url'
    sheet = new Spreadsheet(spreadsheetUrl)
    sheet.useServiceAccountAuth creds, (err) ->
      if err
        callback makeError("Error occurred while authenticating", err)
      else
        sheet.getInfo (err, info) ->
          if err
            callback makeError("Error occurred while getting sheet info", err)
          else
            paymentStatusSheet = info.worksheets[1]
            options =
              range: "R#{moneyRow}C#{receivedCol}:R#{moneyRow}C#{outstandingCol+1}"
            paymentStatusSheet.getCells options, (err, cells) ->
              if err
                callback makeError("Error occurred while getting cells with range: #{options.range}", err)
              else
                received = parseInt(cells[0].value)
                outstanding = parseInt(cells[1].value)
                callback(null, makeMoney(received, outstanding))

  getCurrentMoney = () ->
    robot.brain.get('money.currentMoney') or makeMoney(0, 0)

  setCurrentMoney = (money) ->
    robot.brain.set('money.currentMoney', money)

  moneyEquals = (a, b) ->
    return a.total == b.total and a.received == b.received

  setTopic = (money) ->
    if not moneyEquals(money, getCurrentMoney())
      setCurrentMoney(money)
      robot.adapter.topic { room: config('channel') }, formatTopic(money)

  updateTopic = () ->
    getMoney (err, money) ->
      if not err
        setTopic(money)

  setInterval(updateTopic, 10*60*1000)

  robot.respond /(\$|money)$/i, (res) ->
    getMoney (err, money) ->
      if err
        res.send "#{err.message}: #{err.err}"
      else
        setTopic(money)
        res.send formatMessage(money)
