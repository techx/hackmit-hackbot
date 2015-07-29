# Description:
#   HackMIT sponsorship money
#
# Configuration:
#   HUBOT_HACKMIT_GOOGLE_APIS_TOKEN
#   MONEY_SPREADSHEET_URL
#   GOOGLE_PRIV_KEY_ID
#   GOOGLE_PRIV_KEY
#   GOOGLE_CLIENT_EMAIL
#   GOOGLE_CLIENT_ID
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
googlePrivKeyId = getOrDie("GOOGLE_PRIV_KEY_ID")
googlePrivKey = getOrDie("GOOGLE_PRIV_KEY")
googleClientEmail = getOrDie("GOOGLE_CLIENT_EMAIL")
googleClientId = getOrDie("GOOGLE_CLIENT_ID")

creds =
  private_key_id: googlePrivKeyId
  private_key: googlePrivKey
  client_email: googleClientEmail
  client_id: googleClientId
  type: "serviceAccount"

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

  
