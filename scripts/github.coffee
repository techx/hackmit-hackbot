# Description:
#   GitHub stuff.
#
# Configuration:
#   HUBOT_GITHUB_USERNAME
#   HUBOT_GITHUB_PASSWORD
#   HUBOT_GITHUB_ORGANIZATION
#
# Commands:
#   hubot github issue create <repo> "<title>" "<description>"
#
# Author:
#   anishathalye

GitHubApi = require('github')

module.exports = (robot) ->

  config = require('hubot-conf')('github', robot)

  github = () ->
    user = config 'username'
    pass = config 'password'

    gh = new GitHubApi(version: '3.0.0')
    gh.authenticate type: 'basic', username: user, password: pass
    gh

  # using '[\s\S]' to match multiline (instead of just '.')
  robot.respond /github issue create ([A-Za-z0-9_.-]+) "(.+)" "([\s\S]+)"/i, (res) ->
    creator = res.message.user.name
    repo = res.match[1]
    title = res.match[2]
    desc = "#{res.match[3]}\n\n(submitted by #{creator})"
    org = config 'organization'
    issues = github().issues
    issues.create user: org, repo: repo, title: title, body: desc, (err, data) ->
      if not err
        res.send "Created issue ##{data.number} in #{org}/#{repo}."
      else
        res.send "Error creating issue."
