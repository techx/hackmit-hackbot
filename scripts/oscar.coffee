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

ERR_MSG = "Sorry, there was an error completing your request."

getHttp = (url, callback) ->
  try
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

getStatuses = (callback) ->
  url = process.env.HUBOT_OSCAR_BASE_URL + '/status'
  getHttp url, callback

getMeta = (callback) ->
  url = process.env.HUBOT_OSCAR_BASE_URL
  getHttp url, callback

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

formatMeta = (callback) ->
  getMeta (meta, err) ->
    if err
      callback ERR_MSG
    else
      uptimeMs = parseInt(meta.uptime) * 1000
      msg = ':clock12: ' + relative_time(new Date(new Date() - uptimeMs))
      callback msg

module.exports = (robot) ->

  robot.respond /oscar\s*$/i, (res) ->
    formatMeta (msg) ->
      res.send msg

  robot.respond /status\s*$/i, (res) ->
    getStatuses (statuses, err) ->
      if err
        res.send ERR_MSG
      else
        res.send formatStatuses(statuses)
        formatMeta (msg) ->
          res.send msg

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

`
function relative_time(date) {
  var relative_to = (arguments.length > 1) ? arguments[1] : new Date(); //defines relative to what ..default is now
  var delta = parseInt((relative_to.getTime()-date)/1000);
  delta=(delta<2)?2:delta;
  var r = '';
  if (delta < 60) {
    r = delta + ' seconds';
  } else if(delta < 120) {
    r = 'a minute';
  } else if(delta < (45*60)) {
    r = (parseInt(delta / 60, 10)).toString() + ' minutes';
  } else if(delta < (2*60*60)) {
    r = 'an hour';
  } else if(delta < (24*60*60)) {
    r = '' + (parseInt(delta / 3600, 10)).toString() + ' hours';
  } else if(delta < (48*60*60)) {
    r = 'a day';
  } else {
    r = (parseInt(delta / 86400, 10)).toString() + ' days';
  }
  return 'about ' + r;
}
`
