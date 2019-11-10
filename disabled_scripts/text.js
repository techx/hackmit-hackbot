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

const config = require('hubot-conf');

const BRAIN_LOCATION = 'text.numbers';

module.exports = (robot) => {
  const conf = config('text', robot);

  const addNumber = (number, name) => {
    const mapping = robot.brain.get(BRAIN_LOCATION) || {};
    mapping[number] = name;
    robot.brain.set(BRAIN_LOCATION, mapping);
  };

  const removeNumber = (number) => {
    const mapping = robot.brain.get(BRAIN_LOCATION) || {};
    delete mapping[number];
    robot.brain.set(BRAIN_LOCATION, mapping);
  };

  const getName = (number) => {
    const mapping = robot.brain.get(BRAIN_LOCATION) || {};
    return mapping[number];
  };

  const getNumber = (name) => {
    const mapping = robot.brain.get(BRAIN_LOCATION) || {};
    return Object.keys(mapping).find((key) => mapping[key] === name);
  };

  robot.router.post('/text/receive', (req, res) => {
    res.header('Content-Type', 'text/xml').send('<Response></Response>');
    let number = req.body.From;
    let message = req.body.Body;
    let decorator = 'Twilio';
    if (req.body.AccountSid === conf('account')) {
      const matches = message.match(/(\+?[0-9]+) - (.+)$/);
      if (matches) {
        [, number, message] = matches;
        decorator = 'Google Voice';
      }
      const name = getName(number) ? getName(number) : number;
      robot.messageRoom(
        conf('channel'),
        `[${decorator}] Text from ${name}: ${message}`,
      );
    }
  });

  robot.respond(/text add (\+?[0-9]+) (.+)$/i, (res) => {
    const number = res.match[1];
    const name = res.match[2];
    addNumber(number, name);
    res.send(`Added: \`${number}\` for \`${name}\``);
  });

  robot.respond(/text numberof (.+)$/i, (res) => {
    const name = res.match[1];
    const number = getNumber(name);
    if (number) {
      return res.send(`\`${name}\` is \`${number}\``);
    }
    return res.send(`Could not find number for \`${name}\``);
  });

  robot.respond(/text whois (\+?[0-9]+)$/i, (res) => {
    const number = res.match[1];
    const name = getName(number);
    if (name) {
      return res.send(`\`${number}\` is \`${name}\``);
    }
    return res.send(`Could not find name for \`${number}\``);
  });

  robot.respond(/text remove (\+?[0-9]+)$/i, (res) => {
    const number = res.match[1];
    removeNumber(number);
    res.send(`Removed: \`${number}\``);
  });
};
