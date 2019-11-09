// Description:
//   Text reciever
//
// Configuration:
//   HUBOT_TEXT_CHANNEL - channel to send messages in
//   HUBOT_TEXT_ACCOUNT - Account SID for verification
//
// Commands:
//   hubot text add <number> <name> - add a number to the list (make sure to add the +)
//   hubot text numberof <name> - gets the number of the name
//   hubot text whois <number> - gets the name of the person with that number
//   hubot text remove <number>
//
// Author:
//   Detry322
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const BRAIN_LOCATION = "text.numbers";

module.exports = function(robot) {
  const config = require("hubot-conf")("text", robot);

  const addNumber = function(number, name) {
    const mapping = robot.brain.get(BRAIN_LOCATION) || {};
    mapping[number] = name;
    return robot.brain.set(BRAIN_LOCATION, mapping);
  };

  const removeNumber = function(number) {
    const mapping = robot.brain.get(BRAIN_LOCATION) || {};
    delete mapping["number"];
    return robot.brain.set(BRAIN_LOCATION, mapping);
  };

  const getName = function(number) {
    const mapping = robot.brain.get(BRAIN_LOCATION) || {};
    return mapping[number];
  };

  const getNumber = function(name) {
    const mapping = robot.brain.get(BRAIN_LOCATION) || {};
    for (let number in mapping) {
      const value = mapping[number];
      if (value === name) {
        return number;
      }
    }
    return undefined;
  };

  robot.router.post("/text/receive", function(req, res) {
    res.header("Content-Type", "text/xml").send("<Response></Response>");
    let number = req.body.From;
    let message = req.body.Body;
    let decorator = "Twilio";
    if (req.body.AccountSid === config("account")) {
      const matches = message.match(/(\+?[0-9]+) - (.+)$/);
      if (matches != null) {
        number = matches[1];
        message = matches[2];
        decorator = "Google Voice";
      }
      const name = getName(number) ? getName(number) : number;
      return robot.messageRoom(
        config("channel"),
        `[${decorator}] Text from ${name}: ${message}`
      );
    }
  });

  robot.respond(/text add (\+?[0-9]+) (.+)$/i, function(res) {
    const number = res.match[1];
    const name = res.match[2];
    addNumber(number, name);
    return res.send(`Added: \`${number}\` for \`${name}\``);
  });

  robot.respond(/text numberof (.+)$/i, function(res) {
    const name = res.match[1];
    const number = getNumber(name);
    if (number) {
      return res.send(`\`${name}\` is \`${number}\``);
    } else {
      return res.send(`Could not find number for \`${name}\``);
    }
  });

  robot.respond(/text whois (\+?[0-9]+)$/i, function(res) {
    const number = res.match[1];
    const name = getName(number);
    if (name) {
      return res.send(`\`${number}\` is \`${name}\``);
    } else {
      return res.send(`Could not find name for \`${number}\``);
    }
  });

  return robot.respond(/text remove (\+?[0-9]+)$/i, function(res) {
    const number = res.match[1];
    removeNumber(number);
    return res.send(`Removed: \`${number}\``);
  });
};
