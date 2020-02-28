// Description:
//   HackMIT sponsorship money
//
// Commands:
//   hubot money / hubot $ - get how much money we have collected
//
// Author:
//   katexyu, cmnord
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const Spreadsheet = require('google-spreadsheet');
const config = require('hubot-conf');
const creds = require('../hackmit-money-2015-credentials.json');

const formatMessage = (money) => {
  const { received } = money;
  const { outstanding } = money;
  const { total } = money;
  return `*Received:* $${received}K\n*Outstanding:* $${outstanding}K\n*Total:* $${total}K`;
};

const formatTopic = (money) => formatMessage(money).replace(/\n/g, ' ');

const makeMoney = (received, outstanding) => ({
  received,
  outstanding,
  total: received + outstanding,
});

const makeError = (message, err) => ({
  message,
  err,
});

module.exports = (robot) => {
  const conf = config('money', robot);
  const getMoney = (callback) => {
    const moneyRow = parseInt(conf('row'), 10);
    const receivedCol = parseInt(conf('received.col'), 10);
    const outstandingCol = parseInt(conf('outstanding.col'), 10);
    const spreadsheetUrl = conf('spreadsheet.url');
    const sheet = new Spreadsheet(spreadsheetUrl);
    return sheet.useServiceAccountAuth(creds, (err) => {
      if (err) {
        return callback(makeError('Error occurred while authenticating', err));
      }
      return sheet.getInfo((err2, info) => {
        if (err2) {
          return callback(makeError('Error occurred while getting sheet info', err2));
        }
        const paymentSheetName = conf('spreadsheet.tabname');
        const paymentStatusSheet = info.worksheets.find((ws) => ws.title === paymentSheetName);
        const options = {
          range: `R${moneyRow}C${receivedCol}:R${moneyRow}C${outstandingCol + 1}`,
        };
        return paymentStatusSheet.getCells(options, (err3, cells) => {
          if (err3) {
            return callback(
              makeError(
                `Error occurred while getting cells with range: ${options.range}`,
                err3,
              ),
            );
          }
          const received = parseInt(cells[0].value, 10);
          const outstanding = parseInt(cells[1].value, 10);
          return callback(null, makeMoney(received, outstanding));
        });
      });
    });
  };

  const getCurrentMoney = () => robot.brain.get('money.currentMoney') || makeMoney(0, 0);

  const setCurrentMoney = (money) => robot.brain.set('money.currentMoney', money);

  const moneyEquals = (a, b) => a.total === b.total && a.received === b.received;

  const setTopic = (money) => {
    if (!moneyEquals(money, getCurrentMoney())) {
      setCurrentMoney(money);
      robot.adapter.topic({ room: conf('channel') }, formatTopic(money));
    }
  };

  const updateTopic = () => getMoney((err, money) => {
    if (!err) {
      setTopic(money);
    }
  });

  setInterval(updateTopic, 10 * 60 * 1000);

  return robot.respond(/(\$|money)$/i, (res) => getMoney((err, money) => {
    if (err) {
      return res.send(`${err.message}: ${err.err}`);
    }
    setTopic(money);
    return res.send(formatMessage(money));
  }));
};
