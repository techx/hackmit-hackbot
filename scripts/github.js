// Description:
//   GitHub stuff.
//
// Configuration:
//   HUBOT_GITHUB_USERNAME
//   HUBOT_GITHUB_PASSWORD
//   HUBOT_GITHUB_ORGANIZATION
//
// Commands:
//   hubot github issue create <repo> "<title>" "<description>"
//
// Author:
//   anishathalye
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

const GitHubApi = require("github");

module.exports = function(robot) {
  const config = require("hubot-conf")("github", robot);

  const github = function() {
    const user = config("username");
    const pass = config("password");

    const gh = new GitHubApi({ version: "3.0.0" });
    gh.authenticate({ type: "basic", username: user, password: pass });
    return gh;
  };

  // using '[\s\S]' to match multiline (instead of just '.')
  return robot.respond(
    /github issue create ([A-Za-z0-9_.-]+) "(.+)" "([\s\S]+)"/i,
    function(res) {
      const creator = res.message.user.name;
      const repo = res.match[1];
      const title = res.match[2];
      const desc = `${res.match[3]}\n\n(submitted by ${creator})`;
      const org = config("organization");
      const { issues } = github();
      return issues.create({ user: org, repo, title, body: desc }, function(err, data) {
        if (!err) {
          return res.send(`Created issue #${data.number} in ${org}/${repo}.`);
        } else {
          return res.send("Error creating issue.");
        }
      });
    }
  );
};
