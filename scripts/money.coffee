# Description:
#   HackMIT sponsorship money
#
# Configuration:
#   MONEY_SPREADSHEET_URL
#
# Commands:
#   hubot money / hubot $ - get how much money we have collected
#
# Author:
#   Kate Yu (katexyu)

util = require('util')
Spreadsheet = require("google-spreadsheet");

# These are public but whatever
MONEY_ROW = 2
RECEIVED_COL = 11
OUTSTANDING_COL = 12

getOrDie = (variable) ->
  res = process.env[variable]
  if not res?
    throw new Error("Failed to get environment variable '#{variable}'")
  else
    res

spreadsheetUrl = getOrDie("MONEY_SPREADSHEET_URL")

creds = require('../hackmit-money-2015-credentials.json')

sheet = new Spreadsheet(spreadsheetUrl);

module.exports = (robot) ->
  robot.respond /(\$|money)$/i, (res) ->
    sheet.useServiceAccountAuth creds, (err) ->
      if err
        res.send "Error occurred"
      else
        sheet.getInfo (err, info) ->
          if err
            res.send "Error occurred"
          else
            paymentStatusSheet = info.worksheets[1]
            options = 
              range: "R#{MONEY_ROW}C#{RECEIVED_COL}:R#{MONEY_ROW}C#{OUTSTANDING_COL+1}"
            console.log paymentStatusSheet
            console.log options
            paymentStatusSheet.getCells options, (err, cells) ->
              if err
                res.send "Error occurred"
              else
                res.send "*Received:* $#{cells[0].value}\n*Outstanding:* $#{cells[1].value}"

  
