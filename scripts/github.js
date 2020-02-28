// Description:
//   GitHub stuff.
//
// Configuration:
//   HUBOT_GITHUB_TOKEN - Personal access token for the account
//   HUBOT_GITHUB_ORGANIZATION
//
// Commands:
//   hubot github issue create <repo> "<title>" "<description>"
//
// Author:
//   anishathalye, cmnord

const config = require('hubot-conf');
const Octokit = require('@octokit/rest');

module.exports = (robot) => {
  const conf = config('github', robot);

  const github = () => {
    const pass = conf('password');
    return new Octokit({ auth: pass });
  };

  // using '[\s\S]' to match multiline (instead of just '.')
  return robot.respond(
    /github issue create ([A-Za-z0-9_.-]+) "(.+)" "([\s\S]+)"/i,
    (res) => {
      const creator = res.message.user.name;
      const [, repo, title, body] = res.match;
      const desc = `${body}\n\n(submitted by ${creator})`;
      const org = conf('organization');
      const { issues } = github();
      issues.create({
        owner: org, repo, title, body: desc,
      }).then((issueRes) => res.send(`Created issue #${issueRes.data.number} in ${org}/${repo}.`))
        .catch((err) => res.send(`Error creating issue: ${err}.`));
    },
  );
};
