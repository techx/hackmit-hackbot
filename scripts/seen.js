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
const timeago = require('timeago');

const clean = (thing) => (thing || '').toLowerCase().trim();

const isPM = (msg) => {
  try {
    const { pm } = msg.message.user;
    if (msg.message.user.room === msg.message.user.name) {
      return true;
    }
    return pm;
  } catch (error) {
    return false;
  }
};

const ircname = (msg) => {
  try {
    return msg.message.user.name;
  } catch (error) {
    return false;
  }
};

const ircchan = (msg) => {
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

    this.robot.brain.on('loaded', this.load);
    if (this.robot.brain.data.users.length) {
      this.load();
    }
  }

  load() {
    if (this.robot.brain.data.seen) {
      this.cache = this.robot.brain.data.seen;
    }
    this.robot.brain.data.seen = this.cache;
  }

  add(user, channel) {
    this.robot.logger.debug(`seen.add ${clean(user)} on ${channel}`);
    this.cache[clean(user)] = {
      chan: channel,
      date: new Date() - 0,
    };
  }

  last(user) {
    const left = this.cache[clean(user)];
    return left != null ? left : {};
  }

  usersSince(hoursAgo) {
    const HOUR_MILLISECONDS = 60 * 60 * 1000;
    const seenSinceTime = new Date(Date.now() - hoursAgo * HOUR_MILLISECONDS);
    return Object.keys(this.cache).filter((nick) => {
      const data = this.cache[nick];
      return data.date > seenSinceTime;
    });
  }
}

module.exports = (robot) => {
  const seen = new Seen(robot);

  // Keep track of last msg heard
  robot.hear(/.*/, (msg) => {
    if (!isPM(msg)) {
      seen.add(ircname(msg), ircchan(msg));
    }
  });

  return robot.respond(/seen @?([-\w.\\^|{}`[\]]+):? ?(.*)/, (msg) => {
    if (msg.match[1] === 'in' && msg.match[2] === 'last 24h') {
      const users = seen.usersSince(24);
      return msg.send(`Active in ${msg.match[2]}: ${users.join(', ')}`);
    }
    robot.logger.debug(`seen check ${clean(msg.match[1])}`);
    const nick = msg.match[1];
    const last = seen.last(nick);
    if (last.date) {
      const dateString = (() => {
        if (config.use_timeago != null) {
          return timeago(new Date(last.date));
        }
        return `at ${new Date(last.date)}`;
      })();

      return msg.send(`${nick} was last seen in ${last.chan} ${dateString}`);
    }
    return msg.send(`I haven't seen ${nick} around lately`);
  });
};
