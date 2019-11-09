/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Description:
//   Warriors game score
//
// Author:
//   detry322

const querystring = require('querystring');

module.exports = function(robot) {

  const config = require('hubot-conf')('util', robot);

  robot.respond(/clear$/, res => res.send((__range__(1, 60, true).map((n) => ".")).join("\n")));

  if (robot.adapterName === "slack") {
      robot.logger.info("Adapter is slack: will terminate on client close");
      robot.adapter.client.on('close', () => process.exit(0));
    } else {
      robot.logger.info("Adapter is not slack, will not terminate on client close");
    }

  return robot.respond(/warriors score/i, res => robot.http("http://espn.go.com/nba/bottomline/scores").get()(function(err, result, body) {
    if (err || (result.statusCode !== 200)) {
      res.send("Had trouble getting the score :(");
      return;
    }
    const qs = querystring.parse(body);
    return res.send(qs.nba_s_left1);
  }));
};

function __range__(left, right, inclusive) {
  let range = [];
  let ascending = left < right;
  let end = !inclusive ? right : ascending ? right + 1 : right - 1;
  for (let i = left; ascending ? i < end : i > end; ascending ? i++ : i--) {
    range.push(i);
  }
  return range;
}