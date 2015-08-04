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

getCompanyRows = (creds, callback) ->
  sheet.useServiceAccountAuth creds, (err) ->
    if err
      callback err
    else
      sheet.getInfo (err, info) ->
        if err
          callback err
        else
          companyStatusSheet = info.worksheets[0]
          companyStatusSheet.getRows callback

module.exports = (robot) ->
  robot.respond /sponsor level (.*) ([A-Za-z0-9]+)/i, (res) ->
    getCompanyRows creds, (err, rows) ->
      if err
        res.send "Error occurred while getting rows: #{err}"
      else
        companyName = res.match[1]
        update = res.match[2]
        cRow = findMatchingRow(rows, companyName)
        if !cRow
          res.send "Didn't find matching company"
        else
          if update not in LEVELS
            res.send "Please provide a valid level: #{LEVELS}"
          else
            cRow[LEVEL_COL] = update
            cRow.save (err) ->
              if err
                res.send "Error while updating cell value: #{err}"
              else
                res.send "Successfully updated #{companyName}"

  robot.respond /sponsor status (.*) ([A-Za-z0-9]+)/i, (res) ->
    getCompanyRows creds, (err, rows) ->
      if err
        res.send "Error occurred while getting rows: #{err}"
      else
        companyName = res.match[1]
        update = res.match[2]
        cRow = findMatchingRow(rows, companyName)
        if !cRow
          res.send "Didn't find matching company"
        else
          if update not in STATUSES
            res.send "Please provide a valid status: #{STATUSES}"
          else
            cRow[STATUS_COL] = update
            cRow.save (err) ->
              if err
                res.send "Error while updating cell value: #{err}"
              else
                res.send "Successfully updated #{companyName}"

  robot.respond /sponsor info (.*)/i, (res) ->
    getCompanyRows creds, (err, rows) ->
      if err
        res.send "Error occurred while getting rows: #{err}"
      else
        companyName = res.match[1]
        update = res.match[2]
        cRow = findMatchingRow(rows, companyName)
        if !cRow
          res.send "Didn't find matching company"
        else
          res.send "*#{cRow[SPONSOR_NAME_COL]}*\n*Status:* #{cRow[STATUS_COL]}\n\
                    *Level:* #{cRow[LEVEL_COL]}\n*Point Person:* #{cRow[POINT_COL]}"
