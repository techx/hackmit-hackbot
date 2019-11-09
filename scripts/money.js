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
const util = require("util");
const Spreadsheet = require("google-spreadsheet");

const creds = require("../hackmit-money-2015-credentials.json");

const formatMessage = function(money) {
  const { received } = money;
  const { outstanding } = money;
  const { total } = money;
  return `*Received:* $${received}K\n*Outstanding:* $${outstanding}K\n*Total:* $${total}K`;
};

const formatTopic = money => formatMessage(money).replace(/\n/g, " ");

const makeMoney = (
  received,
  outstanding //AYY MAKE MONEY
) => ({
  received,
  outstanding,
  total: received + outstanding
});

const makeError = (message, err) => ({
  message,
  err
});

module.exports = function(robot) {
  const config = require("hubot-conf")("money", robot);

  const getMoney = function(callback) {
    const moneyRow = parseInt(config("row"));
    const receivedCol = parseInt(config("received.col"));
    const outstandingCol = parseInt(config("outstanding.col"));
    const spreadsheetUrl = config("spreadsheet.url");
    let sheet = new Spreadsheet(spreadsheetUrl);
    return sheet.useServiceAccountAuth(creds, function(err) {
      if (err) {
        return callback(makeError("Error occurred while authenticating", err));
      } else {
        return sheet.getInfo(function(err, info) {
          if (err) {
            return callback(makeError("Error occurred while getting sheet info", err));
          } else {
            const paymentSheetName = config("spreadsheet.tabname");
            const paymentStatusSheet = (() => {
              const result = [];
              for (sheet of Array.from(info.worksheets)) {
                if (sheet.title === paymentSheetName) {
                  result.push(sheet);
                }
              }
              return result;
            })()[0];
            const options = {
              range: `R${moneyRow}C${receivedCol}:R${moneyRow}C${outstandingCol + 1}`
            };
            return paymentStatusSheet.getCells(options, function(err, cells) {
              if (err) {
                return callback(
                  makeError(
                    `Error occurred while getting cells with range: ${options.range}`,
                    err
                  )
                );
              } else {
                const received = parseInt(cells[0].value);
                const outstanding = parseInt(cells[1].value);
                return callback(null, makeMoney(received, outstanding));
              }
            });
          }
        });
      }
    });
  };

  const getCurrentMoney = () =>
    robot.brain.get("money.currentMoney") || makeMoney(0, 0);

  const setCurrentMoney = money => robot.brain.set("money.currentMoney", money);

  const moneyEquals = (a, b) => a.total === b.total && a.received === b.received;

  const setTopic = function(money) {
    if (!moneyEquals(money, getCurrentMoney())) {
      setCurrentMoney(money);
      return robot.adapter.topic({ room: config("channel") }, formatTopic(money));
    }
  };

  const updateTopic = () =>
    getMoney(function(err, money) {
      if (!err) {
        return setTopic(money);
      }
    });

  setInterval(updateTopic, 10 * 60 * 1000);

  return robot.respond(/(\$|money)$/i, res =>
    getMoney(function(err, money) {
      if (err) {
        return res.send(`${err.message}: ${err.err}`);
      } else {
        setTopic(money);
        return res.send(formatMessage(money));
      }
    })
  );
};
