// Description:
//   HackMIT registration statistics.
//
// Configuration:
//   HUBOT_HACKMIT_AUTH_TOKEN
//
// Commands:
//   hubot reg stats|summary - get HackMIT reg stats summary
//   hubot reg fetch - force a fetch of data from the server
//
// Author:
//   Detry322
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const config = require('hubot-conf');
const timeago = require('timeago');

const formatSummary = (data) => {
  const { gender } = data.demo;

  const numSaved = gender.M + gender.F + gender.O + gender.N;

  const minPercentM = Math.round((100 * gender.M) / numSaved);
  const maxPercentM = Math.round(
    (100 * (gender.M + gender.N)) / numSaved,
  );
  const minPercentF = Math.round((100 * gender.F) / numSaved);
  const maxPercentF = Math.round(
    (100 * (gender.F + gender.N)) / numSaved,
  );
  const percentO = Math.round((100 * gender.O) / numSaved);
  const percentN = Math.round((100 * gender.N) / numSaved);

  return `*=== Registration Stats ===*
*Verified*: ${data.verified}
*Saved:* ${numSaved} (_M: ${minPercentM}-${maxPercentM}% F: ${minPercentF}-${maxPercentF}% O: ${percentO}% N: ${percentN}%_)
*Submitted:* ${data.submitted} (_${Math.round((100 * data.submitted) / numSaved)}%_)
*Confirmed:* ${data.confirmed} (_${Math.round((100 * data.confirmed) / data.admitted)}%_)\
`;
};

// percentage breakdown for confirm, add back later
// (_#{Math.round(100 * data.confirmed / data.admitted)}%_) #{nonMale}% non-male_
//  mit = Math.round(100 * data.confirmedMit / data.confirmed)

module.exports = (robot) => {
  const conf = config('hackmit', robot);

  const stats = { data: null, time: null };

  const getStats = (res, callback) => robot
    .http('https://my.hackmit.org/api/users/stats')
    .header('Accept', 'application/json')
    .header('x-access-token', conf('auth.token'))
    .get()((err, httpResponse, body) => {
      if (!err && httpResponse.statusCode === 200) {
        try {
          const data = JSON.parse(body);
          if (stats.data === null) {
            try {
              robot.adapter.topic(
                { room: conf('stats.room', '#botspam') },
                `Submitted: ${data.submitted}`,
              );
            } catch (error1) {
              // if room is set to some nonexistent room (to disable it)
              console.error(error1);
            }
          }
          stats.data = data;
          stats.time = new Date(data.lastUpdated);
          if (callback != null && res != null) {
            callback(res);
          }
        } catch (error) {
          // cry
          console.log(error);
        }
      }
    });

  setInterval(getStats, 3 * 60 * 1000);

  const getStatsOrCache = (res, callback) => {
    if (stats.data != null) {
      return callback(res);
    }
    return getStats(res, callback);
  };

  const print = (res, text) => {
    const delta = timeago(stats.time);
    let message = `_Up to date as of ${delta}._\n`;
    message += text;
    return res.send(message);
  };

  const printSummary = (res) => print(res, formatSummary(stats.data));

  robot.respond(/reg fetch$/i, (res) => getStats(res, (res2) => res2.send('Fetched new data!')));

  robot.respond(/reg stats$/i, (res) => getStatsOrCache(res, printSummary));

  return robot.respond(/reg sum(mary)?$/i, (res) => getStatsOrCache(res, printSummary));
};
