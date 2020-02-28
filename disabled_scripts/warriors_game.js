// Description:
//   Warriors game score
//
// Author:
//   detry322

const querystring = require('querystring');

let rangeFn;

module.exports = (robot) => {
  robot.respond(/clear$/, (res) => res.send((rangeFn(1, 60, true).map(() => '.')).join('\n')));

  if (robot.adapterName === 'slack') {
    robot.logger.info('Adapter is slack: will terminate on client close');
    robot.adapter.client.on('close', () => process.exit(0));
  } else {
    robot.logger.info('Adapter is not slack, will not terminate on client close');
  }

  robot.respond(/warriors score/i, (res) => robot.http('http://www.espn.com/nba/bottomline/scores').get()((err, result, body) => {
    if (err || (result.statusCode !== 200)) {
      res.send('Had trouble getting the score :(');
      return;
    }
    const qs = querystring.parse(body);
    res.send(qs.nba_s_left1);
  }));
};

rangeFn = (left, right, inclusive) => {
  const range = [];
  const ascending = left < right;
  let end;
  if (!inclusive) {
    end = right;
  } else {
    end = ascending ? right + 1 : right - 1;
  }
  for (let i = left; ascending ? i < end : i > end; ascending ? i += 1 : i -= 1) {
    range.push(i);
  }
  return range;
};
