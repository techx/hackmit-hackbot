# Description:
#   HackMIT sponsorship money
#
# Configuration:
#   MONEY_SPREADSHEET_URL
#   MONEY_RECEIVED_COL
#   MONEY_OUTSTANDING_COL
#
# Commands:
#   hubot money / hubot $ - get how much money we have collected
#
# Author:
#   Kate Yu (katexyu)

util = require('util')
Spreadsheet = require("google-spreadsheet");

getOrDie = (variable) ->
  res = process.env[variable]
  if not res?
    throw new Error("Failed to get environment variable '#{variable}'")
  else
    res
# These are public but whatever
MONEY_ROW = 2
RECEIVED_COL = getOrDie("MONEY_RECEIVED_COL")
OUTSTANDING_COL = getOrDie("MONEY_OUTSTANDING_COL")

spreadsheetUrl = getOrDie("MONEY_SPREADSHEET_URL")

creds = require('../hackmit-money-2015-credentials.json')

sheet = new Spreadsheet(spreadsheetUrl);

module.exports = (robot) ->
  robot.respond /(\$|money)$/i, (res) ->
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
              range: "R#{MONEY_ROW}C#{RECEIVED_COL}:R#{MONEY_ROW}C#{OUTSTANDING_COL+1}"
            paymentStatusSheet.getCells options, (err, cells) ->
              if err
                res.send "Error occurred while getting cells: #{err} with options: #{options}"
              else
                received = parseInt(cells[0].value)
                outstanding = parseInt(cells[1].value)
                res.send "*Received:* $#{received}\n*Outstanding:* $#{outstanding}\n*Total:* $#{received+outstanding}"

  
