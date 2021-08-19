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
const { GoogleSpreadsheet } = require('google-spreadsheet');
const config = require('hubot-conf');
const creds = require('../hackmit-money-2021-credentials.json');

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

async function updateMoney(robot) {
  const conf = config('money', robot);
  const getMoney = async function (callback) {
    const moneyRow = parseInt(conf('row'), 10);
    const receivedCol = parseInt(conf('received.col'), 10);
    const outstandingCol = parseInt(conf('outstanding.col'), 10);
    const paymentSheetName = conf('spreadsheet.tabname');
    const spreadsheetUrl = conf('spreadsheet.url');

    const doc = new GoogleSpreadsheet(spreadsheetUrl);
    await doc.useServiceAccountAuth(creds);
    await doc.loadInfo();

    const sheet = doc.sheetsByTitle[paymentSheetName];

    await sheet.loadCells({
      startRowIndex: moneyRow,
      endRowIndex: moneyRow + 1,
      startColumnIndex: receivedCol,
      endColumnIndex: outstandingCol + 1
    });

    const received = sheet.getCell(moneyRow, receivedCol).value / 1000;
    const outstanding = sheet.getCell(moneyRow, outstandingCol).value / 1000;
    callback(null, makeMoney(received, outstanding));
  };

  const getCurrentMoney = () => makeMoney(0, 0);

  const moneyEquals = (a, b) => a.total === b.total && a.received === b.received;

  const setTopic = (money) => {
    if (!moneyEquals(money, getCurrentMoney())) {
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

module.exports = updateMoney;
