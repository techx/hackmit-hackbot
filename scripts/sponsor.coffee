# Description:
#   HackMIT update sponsors
#
# Configuration:
#   MONEY_SPREADSHEET_URL
#
# Commands:
#   hubot sponsor info <company> - get current sponsor status
#   hubot sponsor status <company> <status> - update status of company
#   hubot sponsor level <company> <level> - update sponsorship level of company
#
# Author:
#   katexyu

util = require('util')
Spreadsheet = require("google-spreadsheet")

getOrDie = (variable) ->
  res = process.env[variable]
  if not res?
    throw new Error("Failed to get environment variable '#{variable}'")
  else
    res

findMatchingRow = (rows, companyName) ->
  for row in rows
    if companyName.toLowerCase() == row[SPONSOR_NAME_COL].toLowerCase()
      return row
  return

SPONSOR_NAME_COL = "company"
STATUS_COL = "status"
DATE_COL = "dateoflastcontact"
LEVEL_COL = "level"
POINT_COL = "pointperson"

STATUSES = ["Talking", "Pinged", "Emailed", "Invoiced", "Paid", "Rejected"]
LEVELS = ["0Other", "1Platinum", "2Gold", "3Silver", "4Bronze", "5Startup", "9NotSponsoring"]

spreadsheetUrl = getOrDie("MONEY_SPREADSHEET_URL")

creds = require('../hackmit-money-2015-credentials.json')

sheet = new Spreadsheet(spreadsheetUrl)

getCompanyRow = (creds, callback) ->
  sheet.useServiceAccountAuth creds, (err) ->
    if err
      callback err
    else
      sheet.getInfo (err, info) ->
        if err
          callback err
        else
          companyStatusSheet = info.worksheets[0]
          companyStatusSheet.getRows (err, rows) ->
            if err
              callback(err)
            else
              companyName = res.match[1]
              update = res.match[2]
              row = findMatchingRow(rows, companyName)
              callback(null, row, companyName, update)

module.exports = (robot) ->
  robot.respond /sponsor level (.*) ([A-Za-z0-9]+)/i, (res) ->
    getCompanyRow creds, (err, row, company, update) ->
      if err
        res.send "Error while getting company row: #{err}"
      else if !row
        res.send "Didn't find matching company"
      else
        if update not in LEVELS
          res.send "Please provide a valid level: #{LEVELS}"
        else
          row[LEVEL_COL] = update
          row.save (err) ->
            if err
              res.send "Error while updating cell value: #{err}"
            else
              res.send "Successfully updated #{company}"

  robot.respond /sponsor status (.*) ([A-Za-z0-9]+)/i, (res) ->
    getCompanyRow creds, (err, row, company, update) ->
      if err
        res.send "Error while getting company row: #{err}"
      else if !row
        res.send "Didn't find matching company"
      else
        if update not in STATUSES
          res.send "Please provide a valid status: #{STATUSES}"
        else
          row[STATUS_COL] = update
          row.save (err) ->
            if err
              res.send "Error while updating cell value: #{err}"
            else
              res.send "Successfully updated #{company}"

  robot.respond /sponsor info (.*)/i, (res) ->
    getCompanyRow creds, (err, row, company, update) ->
      if err
        res.send "Error while getting company row: #{err}"
      else if !row
        res.send "Didn't find matching company"
      else
        res.send "*#{row[SPONSOR_NAME_COL]}*\n*Status:* #{row[STATUS_COL]}\n*Level:* #{row[LEVEL_COL]}\n*Point Person:* #{row[POINT_COL]}\n*Last Contacted:* #{row[DATE_COL]}"
