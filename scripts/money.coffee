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
  "*Received:* $#{received}\n*Outstanding:* $#{outstanding}\n*Total:* $#{total}"

formatTopic = (money) ->
  formatMessage(money).replace('\n',' ')

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

  currentMoney = makeMoney(0, 0)

  setTopic = () ->
    getMoney (err, money) ->
      if not err and currentMoney != money
        currentMoney = money
        robot.adapter.topic { room: config('channel') }, formatTopic(money)

  setInterval(setTopic, 10*60*1000)

  robot.respond /(\$|money)$/i, (res) ->
    getMoney (err, money) ->
      if err
        res.send "#{err.message}: #{err.err}"
      else
        res.send formatMessage(money)
