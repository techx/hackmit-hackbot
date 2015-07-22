# Description:
#   Oscar status.
#
# Configuration:
#   HUBOT_OSCAR_STATUS_URL
#
# Commands:
#   hubot status - display statuses of all services
#   hubot status <name> - display statsues of services matching name (regex)
#
# Author:
#   anishathalye

http = require('http')

getStatuses = (callback) ->
  try
    url = process.env.HUBOT_OSCAR_STATUS_URL
    http.get url, (res) ->
      body = ''
      res.on 'data', (chunk) ->
        body += chunk
      res.on 'end', () ->
        obj = JSON.parse body
        callback(obj)
      res.on 'error', (er) ->
        callback(null, err)
  catch err
    callback(null, err)

formatStatus = (status) ->
  mark = if status.status == 'failure' then ":broken_heart:" else ":green_heart:"
  msg = "#{mark} *#{status.name}* | _#{status.status}_"
  if status.summary.length > 0
    msg += " (#{status.summary})"
  msg

formatStatuses = (statuses) ->
  arr = JSON.parse(JSON.stringify statuses)
  ok = []
  failed = []
  for item in arr
    if item.status == 'failure'
      failed.push item
    else
      ok.push item
  cmp = (a, b) ->
    ###
    if a.status == 'failure' or b.status == 'failure'
      if a.status != b.status
        if a.status == 'failure'
          return -1
        else
          return 1
    ###
    if a.name > b.name
      return 1
    else if a.name == b.name
      return 0
    else
      return -1
  ok.sort cmp
  failed.sort cmp
  ok = (formatStatus(i) for i in ok)
  failed = (formatStatus(i) for i in failed)
  ret = ok.join '\n'
  if ret.length > 0
    if failed.length > 0
      return "#{ret}\n\n#{failed.join '\n'}"
    else
      return ret
  else
    return failed.join '\n'

filter = (arr, func) ->
  filtered = []
  for item in arr
    if func item
      filtered.push item
  filtered

module.exports = (robot) ->

  robot.respond /status\s*$/i, (res) ->
    getStatuses (statuses, err) ->
      if err
        res.send "Sorry, there was an error completing your request."
      else
        res.send formatStatuses(statuses)

  robot.respond /status (.*)/i, (res) ->
    search = res.match[1]
    getStatuses (statuses, err) ->
      if err
        res.send "Sorry, there was an error completing your request."
      else
        filtered = filter statuses, (status) ->
          status.name.match search
        if filtered.length > 0
          res.send formatStatuses(filtered)
        else
          res.send "Sorry, there were no results matching `#{search}`. Perhaps tweak your regex?"
