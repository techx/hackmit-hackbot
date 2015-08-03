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
LEVEL_COL = "level_2"
POINT_COL = "pointperson"

STATUSES = ["Talking", "Pinged", "Emailed", "Invoiced", "Paid", "Rejected"]
LEVELS = ["0Other", "1Platinum", "2Gold", "3Silver", "4Bronze", "5Startup", "9NotSponsoring"]

spreadsheetUrl = getOrDie("MONEY_SPREADSHEET_URL")

creds = require('../hackmit-money-2015-credentials.json')

sheet = new Spreadsheet(spreadsheetUrl)

module.exports = (robot) ->
  robot.respond /(sponsor) (status|level|info) (.*) (.*)/i, (res) ->
    sheet.useServiceAccountAuth creds, (err) ->
      if err
        res.send "Error occurred while authenticating: #{err}"
      else
        sheet.getInfo (err, info) ->
          if err
            res.send "Error occurred while getting sheet info: #{err}"
          else
            companyStatusSheet = info.worksheets[0]
            companyStatusSheet.getRows (err, rows) ->
              if err
                res.send "Error occurred while getting rows: #{err}"
              else
                action = res.match[1]
                companyName = res.match[2]
                update = res.match[3]
                cRow = findMatchingRow(rows, companyName)
                if !cRow
                  res.send "Didn't find matching company"
                else
                  switch action
                    when "status" then
                      if update not in STATUSES
                        res.send "Please provide a valid status: #{STATUSES}"
                      else
                        cRow[STATUS_COL] = update
                        cRow.save (err) ->
                          if err
                            res.send "Error while updating cell value: #{err}"
                          else
                            res.send "Successfully updated #{companyName}"
                    when "level" then
                      if update not in LEVELS
                        res.send "Please provide a valid level: #{LEVELS}"
                      else
                        cRow[LEVEL_COL] = update
                        cRow.save (err) ->
                          if err
                            res.send "Error while updating cell value: #{err}"
                          else
                            res.send "Successfully updated #{companyName}"
                    when "info" then
                      res.send "*#{cRow[SPONSOR_NAME_COL]}*\n*Status:* #{cRow[STATUS_COL]}\n
                                *Level:* #{cRow[LEVEL_COL]}\n*Point Person:* #{cRow[POINT_COL]}"
                    else
                      res.send "Not a valid action"

