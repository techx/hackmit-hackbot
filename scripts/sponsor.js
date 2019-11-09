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
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS203: Remove `|| {}` from converted for-own loops
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const util = require("util");
const Spreadsheet = require("google-spreadsheet");
const timeago = require("timeago");
const streakapi = require("streakapi");

const findMatchingRow = function(rows, companyName) {
  for (let row of Array.from(rows)) {
    if (companyName.toLowerCase() === row[SPONSOR_NAME_COL].toLowerCase()) {
      return row;
    }
  }
};

var SPONSOR_NAME_COL = "company";
const LEVEL_COL = "level";

// 2017 levels from sponsor spreadsheet
const LEVELS = [
  "Custom",
  "Platinum",
  "Gold",
  "Silver",
  "Bronze",
  "Startup",
  "NotSponsoring"
];

// 2017 keys and statuses from Streak
let STATUSES = {
  "5001": "To Email",
  "5002": "To Respond",
  "5003": "Initial email",
  "5004": "Talking",
  "5005": "Invoiced",
  "5006": "Paid",
  "5007": "Rejected",
  "5008": "Pinged"
};

const creds = require("../hackmit-money-2015-credentials.json");

// Emails from these addresses are not company contacts.
const EMAIL_FILTER = /^(?!.*(@mit\.edu|@hackmit\.org|@gmail\.com)).*/i;

const filterContacts = function(allContacts) {
  const contacts = [];
  for (let contact of Array.from(allContacts)) {
    if (EMAIL_FILTER.test(contact)) {
      contacts.push(contact);
    }
  }
  return contacts;
};

const getCompanyRows = (sheet, callback) =>
  sheet.useServiceAccountAuth(creds, function(err) {
    if (err) {
      return callback(err);
    } else {
      return sheet.getInfo(function(err, info) {
        if (err) {
          return callback(err);
        } else {
          const companyStatusSheet = info.worksheets[0];
          return companyStatusSheet.getRows(callback);
        }
      });
    }
  });

const getCompanyRow = (sheet, res, callback) =>
  getCompanyRows(sheet, function(err, rows) {
    if (err) {
      return callback(err);
    } else {
      const companyName = res.match[1];
      const update = res.match[2];
      const row = findMatchingRow(rows, companyName);
      return callback(null, row, companyName, update);
    }
  });

const getPipeline = (streak, callback) =>
  streak.Pipelines.getAll()
    .then((
      pipelines // Most recent pipeline is index 0
    ) => callback(null, pipelines[0]))
    .catch(err => callback(err));

const formatBox = function(box) {
  let date;
  try {
    date = new Date(box.lastEmailReceivedTimestamp).toISOString().slice(0, 10);
  } catch (err) {
    date = "Never :cry:";
  }
  return `*${box.name}*
:question: ${STATUSES[box.stageKey]}
:point_right: ${box.assignedToSharingEntries[0].fullName}
:e-mail: ${filterContacts(box.emailAddresses).join(", ")}
:alarm_clock: ${date}
:pencil: ${box.notes ? box.notes : ""}`;
};

module.exports = function(robot) {
  const config = require("hubot-conf")("money", robot);

  const streak = function() {
    const streakKey = config("streak.key");
    const str = new streakapi.Streak(streakKey);
    return str;
  };

  const boxes = { data: null, time: null };

  const getStatuses = function(callback) {
    const str = streak();
    return getPipeline(str, function(err, pipeline) {
      if (err) {
        return callback(err);
      } else {
        const statuses = {};
        for (let s in pipeline.stages) {
          statuses[s] = pipeline.stages[s].name;
        }
        return callback(null, statuses);
      }
    });
  };

  const getBoxes = function(callback) {
    const str = streak();
    return getPipeline(str, function(err, pipeline) {
      if (err) {
        return callback(err);
      } else {
        return str.Boxes.getForPipeline(pipeline.pipelineKey)
          .then(function(data) {
            boxes.data = data;
            // TODO: get last updated time
            boxes.time = new Date();
            if (callback != null) {
              return callback(null, boxes);
            }
          })
          .catch(err => callback(err));
      }
    });
  };

  setInterval(getBoxes, 3 * 60 * 1000);

  const getBoxesOrCache = function(res, callback) {
    if (boxes.data != null) {
      return callback(null, boxes);
    } else {
      return getBoxes(callback);
    }
  };

  const print = function(res, text) {
    const delta = timeago(boxes.time);
    let message = "_Up to date as of " + delta + "._\n";
    message += text;
    return res.send(message);
  };

  const printBoxes = (res, boxsubset) =>
    print(
      res,
      (() => {
        const result = [];
        for (let box in boxsubset) {
          result.push(formatBox(boxsubset[box]));
        }
        return result;
      })().join("\n") + `\n_Total: ${boxsubset ? Object.keys(boxsubset).length : 0}_`
    );

  robot.respond(/sponsor fetch$/i, res =>
    getBoxes(function(err, res) {
      if (err) {
        return res.send(`Error while getting boxes: ${err}`);
      } else {
        return res.send("Fetched new data!");
      }
    })
  );

  getStatuses(function(err, stats) {
    if (err) {
      // fails silently
      return console.log(`Error while getting statuses: ${err}`);
    } else {
      return (STATUSES = stats);
    }
  });

  const spreadsheetUrl = config("spreadsheet.url");
  const sheet = new Spreadsheet(spreadsheetUrl);

  // Get a link to the spreadsheet
  robot.respond(/sponsor spreadsheet/i, res =>
    res.send("https://go.hackmit.org/sponsor")
  );

  // Returns a list of companies with the given status
  robot.respond(
    new RegExp(
      "sponsor (" +
        (() => {
          const result = [];
          for (let k of Object.keys(STATUSES || {})) {
            const v = STATUSES[k];
            result.push(v);
          }
          return result;
        })().join("|") +
        ")$",
      "i"
    ),
    res =>
      getBoxesOrCache(res, function(err, boxes) {
        if (err) {
          return res.send(`Error getting boxes: ${err}`);
        } else {
          const status = res.match[1];
          const companies = [];
          for (let box of Array.from(boxes.data)) {
            if (status.toLowerCase() === STATUSES[box.stageKey].toLowerCase()) {
              companies.push(box.name);
            }
          }
          const join = companies.length < 15 ? "\n" : ", ";
          return print(res, `${companies.join(join)}\n_Total: ${companies.length}_`);
        }
      })
  );

  // Returns a list of companies with the given tier
  robot.respond(new RegExp("sponsor (" + LEVELS.join("|") + ")$", "i"), res =>
    getCompanyRows(sheet, function(err, rows) {
      if (err) {
        return res.send(`Error while getting company rows: ${err}`);
      } else {
        const level = res.match[1];
        const companies = [];
        for (let row of Array.from(rows)) {
          if (level.toLowerCase() === row[LEVEL_COL].toLowerCase().substring(1)) {
            companies.push(row[SPONSOR_NAME_COL]);
          }
        }
        return res.send(`*Total:* ${companies.length}\n${companies.join("\n")}`);
      }
    })
  );

  // Update sponsor tier
  robot.respond(/sponsor level (.*) ([A-Za-z0-9]+)/i, res =>
    getCompanyRow(sheet, res, function(err, row, company, update) {
      if (err) {
        return res.send(`Error while getting company row: ${err}`);
      } else if (!row) {
        return res.send("Didn't find matching company");
      } else {
        if (!Array.from(LEVELS).includes(update)) {
          return res.send(`Please provide a valid level:\n${LEVELS.join("\n")}`);
        } else {
          row[LEVEL_COL] = update;
          return row.save(function(err) {
            if (err) {
              return res.send(`Error while updating cell value: ${err}`);
            } else {
              return res.send(`Successfully updated ${company}`);
            }
          });
        }
      }
    })
  );

  return robot.respond(/sponsor info (.*)/i, res =>
    getBoxesOrCache(res, function(err, boxes) {
      if (err) {
        return res.send(`Error getting boxes: ${err}`);
      } else {
        const search = res.match[1];
        const re = new RegExp("^" + search.toLowerCase(), "i");
        const companies = {};
        for (let box of Array.from(boxes.data)) {
          if (re.test(box.name.toLowerCase())) {
            companies[box.name] = box;
          }
        }
        return printBoxes(res, companies);
      }
    })
  );
};
