# Description:
#   HackMIT update sponsors
#
# Configuration:
#   MONEY_SPREADSHEET_URL
#
# Commands:
#   hubot sponsor info <company> - get current sponsor status
#   hubot sponsor level <company> <level> - update sponsorship level of company
#   hubot sponsor <level> - get list of companies sponsoring at the given level
#   hubot sponsor <status> - get a list of companies sponsoring with the given status
#   hubot sponsor spreadsheet - get a link to the master sponsor spreadsheet
#
# Author:
#   katexyu, cmnord

util = require "util"
Spreadsheet = require "google-spreadsheet"
timeago = require "timeago"
streakapi = require "streakapi"

findMatchingRow = (rows, companyName) ->
  for row in rows
    if companyName.toLowerCase() == row[SPONSOR_NAME_COL].toLowerCase()
      return row
  return

SPONSOR_NAME_COL = "company"
LEVEL_COL = "level"

# 2017 levels from sponsor spreadsheet
LEVELS = ["Custom", "Platinum", "Gold", "Silver", "Bronze", "Startup", "NotSponsoring"]

# 2017 keys and statuses from Streak
STATUSES = {
  "5001": "To Email",
  "5002": "To Respond",
  "5003": "Initial email",
  "5004": "Talking",
  "5005": "Invoiced",
  "5006": "Paid",
  "5007": "Rejected",
  "5008": "Pinged",
}

creds = require "../hackmit-money-2015-credentials.json"

# Emails from these addresses are not company contacts.
EMAIL_FILTER = /^(?!.*(@mit\.edu|@hackmit\.org|@gmail\.com)).*/i

filterContacts = (allContacts) ->
  contacts = []
  for contact in allContacts
    if EMAIL_FILTER.test contact
      contacts.push contact
  contacts

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

formatBox = (box) ->
  try
    date = new Date(box.lastEmailReceivedTimestamp).toISOString().slice(0, 10)
  catch err
    date = "Never :cry:"
  """*#{box.name}*
  :question: #{STATUSES[box.stageKey]}
  :point_right: #{box.assignedToSharingEntries[0].fullName}
  :e-mail: #{filterContacts(box.emailAddresses).join(", ")}
  :alarm_clock: #{date}
  :pencil: #{if box.notes then box.notes else ""}"""

module.exports = (robot) ->
  config = require("hubot-conf")("money", robot)

  streak = () ->
    streakKey = config "streak.key"
    str = new streakapi.Streak(streakKey)
    str

  boxes = { data: null, time: null }

  getStatuses = (callback) ->
    str = streak()
    getPipeline str, (err, pipeline) ->
      if err
        callback err
      else
        statuses = {}
        statuses[s] = pipeline.stages[s].name for s of pipeline.stages
        callback(null, statuses)

  getBoxes = (callback) ->
    str = streak()
    getPipeline str, (err, pipeline) ->
      if err
        callback err
      else
        str.Boxes.getForPipeline(pipeline.pipelineKey)
        .then((data) ->
          boxes.data = data
          # TODO: get last updated time
          boxes.time = new Date()
          if callback?
            callback(null, boxes)
        ).catch((err) ->
          callback err
        )

  setInterval(getBoxes, 3*60*1000)

  getBoxesOrCache = (res, callback) ->
    if boxes.data?
      callback null, boxes
    else
      getBoxes callback

  print = (res, text) ->
    delta = timeago boxes.time
    message = "_Up to date as of " + delta + "._\n"
    message += text
    res.send message

  printBoxes = (res, boxsubset) ->
    print(res, (formatBox boxsubset[box] for box of boxsubset).join("\n") + "\n_Total: #{if boxsubset then Object.keys(boxsubset).length else 0}_")

  robot.respond /sponsor fetch$/i, (res) ->
    getBoxes (err, res) ->
      if err
        res.send "Error while getting boxes: #{err}"
      else
        res.send "Fetched new data!"

  getStatuses (err, stats) ->
    if err
      # fails silently
      console.log "Error while getting statuses: #{err}"
    else
      STATUSES = stats

  spreadsheetUrl = config "spreadsheet.url"
  sheet = new Spreadsheet(spreadsheetUrl)

  # Get a link to the spreadsheet
  robot.respond /sponsor spreadsheet/i, (res) ->
    res.send "https://go.hackmit.org/sponsor"

  # Returns a list of companies with the given status
  robot.respond new RegExp("sponsor (" + (v for own k, v of STATUSES).join("|") + ")$", "i"), (res) ->
    getBoxesOrCache res, (err, boxes) ->
      if err
        res.send "Error getting boxes: #{err}"
      else
        status = res.match[1]
        companies = []
        for box in boxes.data
          if status.toLowerCase() == STATUSES[box.stageKey].toLowerCase()
            companies.push box.name
        join = if companies.length < 15 then "\n" else ", "
        print res, "#{companies.join(join)}\n_Total: #{companies.length}_"

  # Returns a list of companies with the given tier
  robot.respond new RegExp("sponsor (" + LEVELS.join("|") + ")$", "i"), (res) ->
    getCompanyRows sheet, (err, rows) ->
      if err
        res.send "Error while getting company rows: #{err}"
      else
        level = res.match[1]
        companies = []
        for row in rows
          if level.toLowerCase() == row[LEVEL_COL].toLowerCase().substring(1)
            companies.push(row[SPONSOR_NAME_COL])
        res.send "*Total:* #{companies.length}\n#{companies.join("\n")}"

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
              res.send "Successfully updated #{company}"

  robot.respond /sponsor info (.*)/i, (res) ->
    getBoxesOrCache res, (err, boxes) ->
      if err
        res.send "Error getting boxes: #{err}"
      else
        search = res.match[1]
        re = new RegExp("^" + search.toLowerCase(), "i")
        companies = {}
        for box in boxes.data
          if re.test box.name.toLowerCase()
            companies[box.name] = box
        printBoxes res, companies
