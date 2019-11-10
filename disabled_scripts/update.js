// Description:
//   Allows hubot to update itself using git pull and npm update.
//   If updates are downloaded you'll need to restart hubot, for example using "hubot
//   die" (restart using a watcher like forever.js).
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

const childProcess = require('child_process');

const restart = (res) => {
  res.send('Restarting...');
  setTimeout(() => process.exit(),
    500); // Give process some time to send message
};

const send = (res, shouldSend, message) => {
  if (shouldSend) {
    res.send(message);
  }
};

const update = (res, sendStd, sendErr) => {
  try {
    send(res, sendStd, 'fetching latest source code...');
    childProcess.exec('git fetch --all >/dev/null 2>&1 && git log --oneline --graph --stat HEAD..@{u} && git reset --hard @{u}', (error, stdout, stderr) => {
      if (error) {
        send(res, sendErr, `git fetch/reset failed: \`\`\`${stderr}\`\`\``);
      } else {
        send(res, sendStd, `\`\`\`${stdout}\`\`\``);
      }
      try {
        send(res, sendStd, 'npm update...');
        childProcess.exec('npm update', (error1, stdout1, stderr1) => {
          if (error1) {
            send(res, sendErr, `npm update failed: \`\`\`${stderr1}\`\`\``);
          } else {
            const output = `${stdout1}`;
            if (/node_modules/.test(output)) {
              send(res, sendStd, `some dependencies updated:\n\`\`\`${output}\`\`\``);
            } else {
              send(res, sendStd, 'all dependencies are up-to-date');
            }
          }
          restart(res);
        });
      } catch (error1) {
        send(res, sendErr, `npm update failed: ${error1}`);
      }
    });
  } catch (error1) {
    send(res, sendErr, `git pull failed: ${error1}`);
  }
};

module.exports = (robot) => {
  robot.respond(/restart( yourself)?$/i, (res) => restart(res));

  robot.respond(/update silent$/i, (res) => {
    res.send('Updating...');
    return update(res, false, true);
  });

  robot.respond(/update super silent$/i, (res) => update(res, false, false));

  robot.respond(/update( yourself)?$/i, (res) => update(res, true, true));
};
