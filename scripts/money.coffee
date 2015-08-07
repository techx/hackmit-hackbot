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

module.exports = (robot) ->
  config = require('hubot-conf')('money', robot)

  robot.respond /(\$|money)$/i, (res) ->
    moneyRow = parseInt(config 'row')
    receivedCol = parseInt(config 'received.col')
    outstandingCol = parseInt(config 'outstanding.col')
    spreadsheetUrl = config 'spreadsheet.url'

    sheet = new Spreadsheet(spreadsheetUrl)

    sheet.useServiceAccountAuth creds, (err) ->
      if err
        res.send "Error occurred while authenticating: #{err}"
      else
        sheet.getInfo (err, info) ->
          if err
            res.send "Error occurred while getting sheet info: #{err}"
          else
            paymentStatusSheet = info.worksheets[1]
            options =
              range: "R#{moneyRow}C#{receivedCol}:R#{moneyRow}C#{outstandingCol+1}"
            paymentStatusSheet.getCells options, (err, cells) ->
              if err
                res.send "Error occurred while getting cells: #{err} with range: #{options.range}"
              else
                received = parseInt(cells[0].value)
                outstanding = parseInt(cells[1].value)
                res.send "*Received:* $#{received}\n*Outstanding:* $#{outstanding}\n*Total:* $#{received+outstanding}"
