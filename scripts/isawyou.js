// Description:
//   A hubot script that keeps track of how many times
//   users have posted images to the #i-saw-you channel
//   (or equivalent, depending on the configuration).
//
// Commands:
//   hubot isawyou leaderboard - shows the top 5 scorers
//   hubot isawyou get <user> - get the number of isawyou points the user has
//   hubot isawyou set <user> <number> - sets user's points to number
//
// Configuration:
//   hubot config isawyou.room is the '#i-saw-you' channel name
//
// Author:
//   Anthony Liu, wiredfool, patcon@gittip

// config
const config = require('hubot-conf');

// helpers
function bind(fn, context, ...args) {
  return function apply() {
    return fn.apply(context, args);
  };
}

/**
 * A class that encapsulate all of the functionality
 * of the ISawYou leaderboard system.
 */
class ISawYou {
  /**
   * Creates a new ISawYou object with the given robot.
   * @param robot the robot whose brain to use
   */
  constructor(robot) {
    this.robot = robot;
    this.cache = {};
    this.load = bind(this.load, this);
    this.SUBTYPE = 'file_share';
    this.robot.brain.on('loaded', this.load);
    if (this.robot.brain.data.users.length > 0) {
      this.load();
    }
  }

  // load the data in the brain in the cache
  load() {
    if (this.robot.brain.data.isawyou) {
      this.cache = this.robot.brain.data.isawyou;
    } else {
      this.robot.brain.data.isawyou = this.cache;
    }
  }

  // adds this message to the msg's user's count if its a pic
  add(msg) {
    const username = msg.message.user.name;
    if (this.isPictureMessage(msg)) {
      this.robot.logger.debug('isawyou.add #{username}');
      if (username in this.cache) {
        this.cache[username] += 1;
      } else {
        this.cache[username] = 1;
      }
      return true;
    }
    return false;
  }

  // increments username's points
  increment(username) {
    if (username in this.cache) {
      this.cache[username] += 1;
    } else {
      this.cache[username] = 1;
    }
  }

  // decrements username's points
  decrement(username) {
    if (username in this.cache) {
      this.cache[username] -= 1;
      if (this.cache[username] < 0) {
        this.cache[username] = 0;
      }
    } else {
      this.cache[username] = 0;
    }
  }

  // sets username's points to newPoints
  set(username, newPoints) {
    this.cache[username] = newPoints;
  }

  // returns the specific user's count
  getCount(username) {
    this.robot.logger.debug('isawyou.get #{username}');
    if (username in this.cache) {
      return this.cache[username];
    }
    return 0;
  }

  // return the top k-scoring users
  // format: [{user: , points: }, ...]
  getTopK(k) {
    // yes there are more efficient ways to do this but
    // practically it really isn't going to make a differnce
    const self = this;
    return Object.keys(this.cache)
      .map((username) => ({ username, points: self.cache[username] }))
      .sort((a, b) => {
        if (a.points === b.points) {
          return a.username > b.username ? 1 : -1;
        }
        return b.points - a.points;
      })
      .slice(0, k);
  }

  // returns true iff the message is a picture message
  isPictureMessage(msg) {
    return msg.message.rawMessage.subtype === this.SUBTYPE;
  }
}

module.exports = (robot) => {
  const robotConfig = config('isawyou', robot);

  // working variables
  const iSawYou = new ISawYou(robot);

  function reportCount(msg, username) {
    const count = iSawYou.getCount(username);
    msg.send(`*${username}* has ${count} i-saw-you points.`);
  }

  // update i-saw-you counts
  robot.hear(/.*/, (msg) => {
    // only listen to messages in the #i-saw-you channel
    if (robotConfig('room') === msg.message.room) {
      const username = msg.message.user.name;
      const matchesInc = msg.message.text.match(/^@([-\w.\\^|{}`[\]]+)\+\+$/);
      const matchesDec = msg.message.text.match(/^@([-\w.\\^|{}`[\]]+)--$/);
      if (matchesInc && matchesInc.length === 2) {
        iSawYou.increment(matchesInc[1]);
        reportCount(msg, matchesInc[1]);
      } else if (matchesDec && matchesDec.length === 2) {
        iSawYou.decrement(matchesDec[1]);
        reportCount(msg, matchesDec[1]);
      } else {
        const added = iSawYou.add(msg);
        if (added) {
          reportCount(msg, username);
        }
      }
    }
  });

  // respond to i-saw-you increments
  robot.respond(/isawyou @?([-\w.\\^|{}`[\]]+)\+\+$/, (msg) => {
    const username = msg.match[1];
    iSawYou.increment(username);
    reportCount(msg, username);
  });

  // respond to i-saw-you leaderboard requests
  robot.respond(/isawyou leaderboard/, (msg) => {
    const k = parseInt(robotConfig('k'), 10);
    const users = iSawYou.getTopK(k);
    const prefix = '~ i-saw-you leaderboard ~\n';
    const message = prefix
      + users.reduce((a, user) => `${a}*${user.username}*: ${user.points} points\n`, '');
    msg.send(message);
  });

  // respond to i-saw-you get requests
  robot.respond(/isawyou get @?([-\w.\\^|{}`[\]]+)$/, (msg) => {
    const username = msg.match[1];
    reportCount(msg, username);
  });

  // respond to point set requests
  robot.respond(/isawyou set @?([-\w.\\^|{}`[\]]+) (\d+)/, (msg) => {
    if (msg.match.length < 3) {
      msg.send('Usage: hackbot isawyou set <user> <number>');
    } else {
      const username = msg.match[1];
      const newPoints = parseInt(msg.match[2], 10);
      iSawYou.set(username, newPoints);
      msg.send(`*${username}* now has ${newPoints} i-saw-you points.`);
    }
  });
};
