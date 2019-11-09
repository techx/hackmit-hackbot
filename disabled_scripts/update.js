/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Description:
//   Allows hubot to update itself using git pull and npm update.
//   If updates are downloaded you'll need to restart hubot, for example using "hubot die" (restart using a watcher like forever.js).
//
//   Shamelessly stolen from: https://github.com/github/hubot-scripts/blob/master/src/scripts/update.coffee
//   ... with some slight modifications.
//
// Dependencies:
//   None
//
// Configuration:
//   None
//
// Commands:
//   hubot update - Performs a git pull and npm update.
//
// Author:
//   benjamine, Detry322

const child_process = require('child_process');
const downloaded_updates = false;

const restart = function(res) {
  res.send("Restarting...");
  return setTimeout(() => process.exit()
  , 500); // Give process some time to send message
};

const send = function(res, should_send, message) {
  if (should_send) {
    return res.send(message);
  }
};

const update = function(res, send_std, send_err) {
  try {
    send(res, send_std, "fetching latest source code...");
    return child_process.exec('git fetch --all >/dev/null 2>&1 && git log --oneline --graph --stat HEAD..@{u} && git reset --hard @{u}', function(error, stdout, stderr) {
      if (error) {
        send(res, send_err, "git fetch/reset failed: ```" + stderr + "```");
      } else {
        send(res, send_std, `\`\`\`${stdout}\`\`\``);
      }
      try {
        send(res, send_std, "npm update...");
        return child_process.exec('npm update', function(error, stdout, stderr) {
          if (error) {
            send(res, send_err, "npm update failed: ```" + stderr + "```");
          } else {
            const output = stdout+'';
            if (/node_modules/.test(output)) {
              send(res, send_std, "some dependencies updated:\n```" + output + "```");
            } else {
              send(res, send_std, "all dependencies are up-to-date");
            }
          }
          return restart(res);
        });
      } catch (error1) {
        error = error1;
        return send(res, send_err, "npm update failed: " + error);
      }
    });
  } catch (error1) {
    const error = error1;
    return send(res, send_err, "git pull failed: " + error);
  }
};

module.exports = function(robot) {

  robot.respond(/restart( yourself)?$/i, res => restart(res));

  robot.respond(/update silent$/i, function(res) {
    res.send("Updating...");
    return update(res, false, true);
  });

  robot.respond(/update super silent$/i, res => update(res, false, false));

  return robot.respond(/update( yourself)?$/i, res => update(res, true, true));
};
