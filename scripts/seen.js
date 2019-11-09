// Description:
//   A hubot script that tracks when/where users were last seen.
//
// Commands:
//   hubot seen <user> - show when and where user was last seen
//   hubot seen in last 24h - list users seen in last 24 hours
//
// Configuration:
//   HUBOT_SEEN_TIMEAGO - If set (to anything), last seen times will be relative
//
// Author:
//   wiredfool, patcon@gittip

/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS104: Avoid inline assignments
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const config = { use_timeago: process.env.HUBOT_SEEN_TIMEAGO };

const clean = thing => (thing || "").toLowerCase().trim();

const is_pm = function(msg) {
  try {
    const { pm } = msg.message.user;
    if (msg.message.user.room === msg.message.user.name) {
      return true;
    } else {
      return pm;
    }
  } catch (error) {
    return false;
  }
};

const ircname = function(msg) {
  try {
    return msg.message.user.name;
  } catch (error) {
    return false;
  }
};

const ircchan = function(msg) {
  try {
    return msg.message.user.room;
  } catch (error) {
    return false;
  }
};

class Seen {
  constructor(robot) {
    this.load = this.load.bind(this);
    this.robot = robot;
    this.cache = {};

    this.robot.brain.on("loaded", this.load);
    if (this.robot.brain.data.users.length) {
      this.load();
    }
  }

  load() {
    if (this.robot.brain.data.seen) {
      return (this.cache = this.robot.brain.data.seen);
    } else {
      return (this.robot.brain.data.seen = this.cache);
    }
  }

  add(user, channel) {
    this.robot.logger.debug(`seen.add ${clean(user)} on ${channel}`);
    return (this.cache[clean(user)] = {
      chan: channel,
      date: new Date() - 0
    });
  }

  last(user) {
    let left;
    return (left = this.cache[clean(user)]) != null ? left : {};
  }

  usersSince(hoursAgo) {
    const HOUR_MILLISECONDS = 60 * 60 * 1000;
    const seenSinceTime = new Date(Date.now() - hoursAgo * HOUR_MILLISECONDS);
    const users = (() => {
      const result = [];
      for (let nick in this.cache) {
        const data = this.cache[nick];
        if (data.date > seenSinceTime) {
          result.push(nick);
        }
      }
      return result;
    })();
    return users;
  }
}

module.exports = function(robot) {
  const seen = new Seen(robot);

  // Keep track of last msg heard
  robot.hear(/.*/, function(msg) {
    if (!is_pm(msg)) {
      return seen.add(ircname(msg), ircchan(msg));
    }
  });

  return robot.respond(/seen @?([-\w.\\^|{}`\[\]]+):? ?(.*)/, function(msg) {
    if (msg.match[1] === "in" && msg.match[2] === "last 24h") {
      const users = seen.usersSince(24);
      return msg.send(`Active in ${msg.match[2]}: ${users.join(", ")}`);
    } else {
      robot.logger.debug(`seen check ${clean(msg.match[1])}`);
      const nick = msg.match[1];
      const last = seen.last(nick);
      if (last.date) {
        const date_string = (() => {
          if (config.use_timeago != null) {
            const timeago = require("timeago");
            return timeago(new Date(last.date));
          } else {
            return `at ${new Date(last.date)}`;
          }
        })();

        return msg.send(`${nick} was last seen in ${last.chan} ${date_string}`);
      } else {
        return msg.send(`I haven't seen ${nick} around lately`);
      }
    }
  });
};
