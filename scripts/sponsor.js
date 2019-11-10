// Description:
//   HackMIT update sponsors
//
// Configuration:
//   MONEY_SPREADSHEET_URL
//
// Commands:
//   hubot sponsor info <company> - get current sponsor status
//   hubot sponsor level <company> <level> - update sponsorship level of company
//   hubot sponsor <level> - get list of companies sponsoring at the given level
//   hubot sponsor <status> - get a list of companies sponsoring with the given status
//   hubot sponsor spreadsheet - get a link to the master sponsor spreadsheet
//
// Author:
//   katexyu, cmnord

const config = require('hubot-conf');
const Spreadsheet = require('google-spreadsheet');
const timeago = require('timeago');
const streakapi = require('streakapi');

const LEVEL_COL = '_cre1l';
const SPONSOR_NAME_COL = 'forhackbotmoneypleasedonoteditthisrow';

const findMatchingRow = (rows, companyName) => rows.find(
  (row) => companyName.toLowerCase() === row[SPONSOR_NAME_COL].toLowerCase(),
);

// 2017 levels from sponsor spreadsheet
const LEVELS = [
  'Custom',
  'Platinum',
  'Gold',
  'Silver',
  'Bronze',
  'Startup',
  'NotSponsoring',
];

// 2017 keys and statuses from Streak
let STATUSES = {
  5001: 'To Email',
  5002: 'To Respond',
  5003: 'Initial email',
  5004: 'Talking',
  5005: 'Invoiced',
  5006: 'Paid',
  5007: 'Rejected',
  5008: 'Pinged',
};

const creds = require('../hackmit-money-2015-credentials.json');

// Emails from these addresses are not company contacts.
const EMAIL_FILTER = /^(?!.*(@mit\.edu|@hackmit\.org|@gmail\.com)).*/i;

const filterContacts = (allContacts) => allContacts.filter((contact) => EMAIL_FILTER.test(contact));

const getCompanyRows = (sheet, callback) => sheet.useServiceAccountAuth(creds, (err) => {
  if (err) {
    return callback(err);
  }
  return sheet.getInfo((err2, info) => {
    if (err2) {
      return callback(err2);
    }
    const companyStatusSheet = info.worksheets[0];
    return companyStatusSheet.getRows(callback);
  });
});

const getCompanyRow = (sheet, res, callback) => getCompanyRows(sheet, (err, rows) => {
  if (err) {
    return callback(err);
  }
  const companyName = res.match[1];
  const update = res.match[2];
  const row = findMatchingRow(rows, companyName);
  return callback(null, row, companyName, update);
});

const getPipeline = (streak, callback) => streak.Pipelines.getAll()
  .then((
    pipelines, // Most recent pipeline is index 0
  ) => callback(null, pipelines[0]))
  .catch((err) => callback(err));

const formatBox = (box) => {
  let date;
  try {
    date = new Date(box.lastEmailReceivedTimestamp).toISOString().slice(0, 10);
  } catch (err) {
    date = 'Never :cry:';
  }
  const assignee = box.assignedToSharingEntries.length > 0 ? box.assignedToSharingEntries[0].fullName : 'No one :cry';
  return `*${box.name}*
:question: ${STATUSES[box.stageKey]}
:point_right: ${assignee}
:e-mail: ${filterContacts(box.emailAddresses).join(', ')}
:alarm_clock: ${date}
:pencil: ${box.notes ? box.notes : ''}`;
};

module.exports = (robot) => {
  const conf = config('money', robot);

  const streak = () => {
    const streakKey = conf('streak.key');
    return new streakapi.Streak(streakKey);
  };

  const boxes = { data: null, time: null };

  const getStatuses = (callback) => {
    const str = streak();
    return getPipeline(str, (err, pipeline) => {
      if (err) {
        return callback(err);
      }
      const statuses = {};
      Object.keys(pipeline.stages).map((s) => {
        statuses[s] = pipeline.stages[s].name;
        return s;
      });
      return callback(null, statuses);
    });
  };

  const getBoxes = (callback) => {
    const str = streak();
    return getPipeline(str, (err, pipeline) => {
      if (err) {
        return callback(err);
      }
      return str.Boxes.getForPipeline(pipeline.pipelineKey)
        .then((data) => {
          boxes.data = data;
          // TODO: get last updated time
          boxes.time = new Date();
          if (callback) {
            callback(null, boxes);
          }
        })
        .catch((err2) => callback(err2));
    });
  };

  setInterval(getBoxes, 3 * 60 * 1000);

  const getBoxesOrCache = (res, callback) => {
    if (boxes.data) {
      return callback(null, boxes);
    }
    return getBoxes(callback);
  };

  const print = (res, text) => {
    const delta = timeago(boxes.time);
    let message = `_Up to date as of ${delta}._\n`;
    message += text;
    res.send(message);
  };

  const printBoxes = (res, boxsubset) => {
    print(
      res,
      `${Object.values(boxsubset).map(formatBox).join('\n')}\n_Total: ${boxsubset ? Object.keys(boxsubset).length : 0}_`,
    );
  };

  robot.respond(/sponsor fetch$/i, (res) => getBoxes((err) => {
    if (err) {
      res.send(`Error while getting boxes: ${err}`);
    }
    res.send('Fetched new data!');
  }));

  getStatuses((err, stats) => {
    if (err) {
      // fails silently
      console.log(`Error while getting statuses: ${err}`);
    }
    STATUSES = stats;
    return STATUSES;
  });

  const spreadsheetUrl = conf('spreadsheet.url');
  const sheet = new Spreadsheet(spreadsheetUrl);

  // Get a link to the spreadsheet
  robot.respond(/sponsor spreadsheet/i, (res) => res.send('https://go.hackmit.org/sponsor'));

  // Returns a list of companies with the given status
  robot.respond(
    new RegExp(
      `sponsor (${Object.values(STATUSES).join('|')})$`,
      'i',
    ),
    (res) => getBoxesOrCache(res, (err, newBoxes) => {
      if (err) {
        res.send(`Error getting boxes: ${err}`);
      }
      const status = res.match[1];
      const companies = newBoxes.data.filter(
        (box) => status.toLowerCase() === STATUSES[box.stageKey].toLowerCase(),
      ).map((box) => box.name);
      const join = companies.length < 15 ? '\n' : ', ';
      print(res, `${companies.join(join)}\n_Total: ${companies.length}_`);
    }),
  );

  // Returns a list of companies with the given tier
  robot.respond(new RegExp(`sponsor (${LEVELS.join('|')})$`, 'i'), (res) => getCompanyRows(sheet, (err, rows) => {
    if (err) {
      res.send(`Error while getting company rows: ${err}`);
    }
    const level = res.match[1].toLowerCase();
    const companies = rows.filter(
      (row) => row[LEVEL_COL] !== undefined && row[LEVEL_COL].toLowerCase() === level,
    ).map((row) => row[SPONSOR_NAME_COL]);
    res.send(`*Total:* ${companies.length}\n${companies.join('\n')}`);
  }));

  // Update sponsor tier
  robot.respond(/sponsor level (.*) ([A-Za-z0-9]+)/i, (res) => getCompanyRow(sheet, res, (err, row, company, update) => {
    if (err) {
      res.send(`Error while getting company row: ${err}`);
    } if (!row) {
      res.send("Didn't find matching company");
    }
    if (!(update in LEVELS)) {
      res.send(`Please provide a valid level:\n${LEVELS.join('\n')}`);
    }
    const newRow = row;
    newRow[LEVEL_COL] = update;
    newRow.save((err2) => {
      if (err2) {
        res.send(`Error while updating cell value: ${err2}`);
      }
      res.send(`Successfully updated ${company}`);
    });
  }));

  robot.respond(/sponsor info (.*)/i, (res) => getBoxesOrCache(res, (err, newBoxes) => {
    if (err) {
      res.send(`Error getting boxes: ${err}`);
    }
    const search = res.match[1];
    const re = new RegExp(`^${search.toLowerCase()}`, 'i');
    const companies = {};
    newBoxes.data.filter((box) => re.test(box.name.toLowerCase())).map((box) => {
      companies[box.name] = box;
      return box;
    });
    printBoxes(res, companies);
  }));
};
