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
#   hubot sponsor date <company> <date> - update company date of last contact
#   hubot sponsor <level> - get list of companies sponsoring at the given level
#   hubot sponsor <status> - get a list of companies sponsoring with the given status
#   hubot sponsor spreadsheet - get a link to the master sponsor spreadsheet
#
# Author:
#   katexyu

util = require('util')
Spreadsheet = require("google-spreadsheet")
streakapi = require('streakapi')

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
CONTACT_COL = "companycontact"


LEVELS = ["Custom", "Platinum", "Gold", "Silver", "Bronze", "Startup", "NotSponsoring"]

creds = require('../hackmit-money-2015-credentials.json')

getCompanyRows = (sheet, callback) ->
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

getCompanyRow = (sheet, res, callback) ->
  getCompanyRows sheet, (err, rows) ->
    if err
      callback(err)
    else
      companyName = res.match[1]
      update = res.match[2]
      row = findMatchingRow(rows, companyName)
      callback(null, row, companyName, update)

getPipeline = (streak, callback) ->
  streak.Pipelines.getAll()
  .then((pipelines) ->
    # Most recent pipeline is index 0
    callback(null, pipelines[0])
  ).catch((err) ->
    callback err
  )

getStatuses = (streak, callback) ->
  getPipeline streak, (err, pipeline) ->
    if err
      callback err
    else
      statuses = {}
      statuses[s] = pipeline.stages[s].name for s of pipeline.stages
      callback(null, statuses)

getBoxes = (streak, callback) ->
  getPipeline streak, (err, pipeline) ->
    if err
      callback err
    else
      streak.Boxes.getForPipeline(pipeline.pipelineKey)
      .then((boxes) ->
        callback(null, boxes)
      ).catch((err) ->
        callback err
      )


module.exports = (robot) ->
  config = require('hubot-conf')('money', robot)

  streakKey = config 'streak.key'
  streak = new streakapi.Streak(streakKey)
  # 2017 keys and statuses from Streak
  STATUSES = {
    '5001': 'To Email',
    '5002': 'To Respond',
    '5003': 'Initial email',
    '5004': 'Talking',
    '5005': 'Invoiced',
    '5006': 'Paid',
    '5007': 'Rejected',
    '5008': 'Pinged',
    '5009': 'AuthFailed'
  }
  getStatuses streak, (err, stats) ->
    if err
      console.log "Error while getting statuses: #{err}"
      # TODO: throw error?
    else
      STATUSES = stats

  spreadsheetUrl = config 'spreadsheet.url'
  sheet = new Spreadsheet(spreadsheetUrl)

  # Get a link to the spreadsheet
  robot.respond /sponsor spreadsheet/i, (res) ->
    res.send "https://go.hackmit.org/sponsor"

  robot.respond /test/i, (res) ->
    getPipeline streak, (err, pipeline) ->
      if err
        res.send "Error while getting pipeline: #{err}"
      else
        res.send JSON.stringify pipeline

  # Returns a list of companies with the given status
  robot.respond new RegExp('sponsor (' + (v for own k, v of STATUSES).join('|') + ')$', 'i'), (res) ->
    getBoxes streak, (err, boxes) ->
      if err
        res.send "Error while getting Streak boxes: #{err}"
      else
        status = res.match[1]
        companies = []
        for box in boxes
          if status.toLowerCase() == STATUSES[box.stageKey].toLowerCase()
            companies.push(box.name)
        join = if companies.length < 15 then '\n' else ', '
        res.send "#{companies.join(join)}\n_Total: #{companies.length}_"

  # Returns a list of companies with the given tier
  robot.respond new RegExp('sponsor (' + LEVELS.join('|') + ')$', 'i'), (res) ->
    getCompanyRows sheet, (err, rows) ->
      if err
        res.send "Error while getting company rows: #{err}"
      else
        level = res.match[1]
        companies = []
        for row in rows
          if level.toLowerCase() == row[LEVEL_COL].toLowerCase().substring(1)
            companies.push(row[SPONSOR_NAME_COL])
        res.send "*Total:* #{companies.length}\n#{companies.join('\n')}"

  # Update sponsor tier
  robot.respond /sponsor level (.*) ([A-Za-z0-9]+)/i, (res) ->
    getCompanyRow sheet, res, (err, row, company, update) ->
      if err
        res.send "Error while getting company row: #{err}"
      else if !row
        res.send "Didn't find matching company"
      else
        if update not in LEVELS
          res.send "Please provide a valid level:\n#{LEVELS.join("\n")}"
        else
          row[LEVEL_COL] = update
          row.save (err) ->
            if err
              res.send "Error while updating cell value: #{err}"
            else
              res.send "Successfully updated #{company}\n*#{row[SPONSOR_NAME_COL]}*\n*Status:* #{row[STATUS_COL]}\n*Level:* #{row[LEVEL_COL]}\n*Point Person:* #{row[POINT_COL]}\n*Company Contact:* #{row[CONTACT_COL]}\n*Last Contacted:* #{row[DATE_COL]}"

  # Update sponsor status
  robot.respond /sponsor status (.*) ([A-Za-z0-9]+)/i, (res) ->
    getCompanyRow sheet, res, (err, row, company, update) ->
      if err
        res.send "Error while getting company row: #{err}"
      else if !row
        res.send "Didn't find matching company"
      else
        if update not in (v for own k, v of STATUSES)
          res.send "Please provide a valid status: #{(v for own k, v of STATUSES).join("\n")}"
        else
          row[STATUS_COL] = update
          today = new Date()
          row[DATE_COL] = (today.getMonth() + 1) + "/" + today.getDate() + "/" + today.getFullYear()
          row.save (err) ->
            if err
              res.send "Error while updating cell value: #{err}"
            else
              res.send "Successfully updated #{company}\n*#{row[SPONSOR_NAME_COL]}*\n*Status:* #{row[STATUS_COL]}\n*Level:* #{row[LEVEL_COL]}\n*Point Person:* #{row[POINT_COL]}\n*Company Contact:* #{row[CONTACT_COL]}\n*Last Contacted:* #{row[DATE_COL]}"

  robot.respond /sponsor date (.*) ([A-Za-z0-9\/]+)/i, (res) ->
    getCompanyRow sheet, res, (err, row, company, update) ->
      if err
        res.send "Error while getting company row: #{err}"
      else if !row
        res.send "Didn't find matching company"
      else
        row[DATE_COL] = update
        row.save (err) ->
          if err
            res.send "Error while updating cell value: #{err}"
          else
            res.send "Successfully updated #{company}\n*#{row[SPONSOR_NAME_COL]}*\n*Status:* #{row[STATUS_COL]}\n*Level:* #{row[LEVEL_COL]}\n*Point Person:* #{row[POINT_COL]}\n*Company Contact:* #{row[CONTACT_COL]}\n*Last Contacted:* #{row[DATE_COL]}"

  # Get sponsor info
  robot.respond /sponsor info (.*)/i, (res) ->
    getCompanyRow sheet, res, (err, row, company, update) ->
      if err
        res.send "Error while getting company row: #{err}"
      else if !row
        res.send "Didn't find matching company"
      else
        res.send "*#{row[SPONSOR_NAME_COL]}*\n*Status:* #{row[STATUS_COL]}\n*Level:* #{row[LEVEL_COL]}\n*Point Person:* #{row[POINT_COL]}\n*Company Contact:* #{row[CONTACT_COL]}\n*Last Contacted:* #{row[DATE_COL]}"
