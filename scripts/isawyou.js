// Description:
//   A hubot script that keeps track of how many times
//   users have posted images to the #i-saw-you channel
//   (or equivalent, depending on the configuration).
//
// Commands:
//   hubot isawyou <user> - msgs the number of isawyou points they have
//   hubot isawyou set <user> <number> - sets user's points to number
//
// Configuration:
//   hubot config isawyou.room is the "#i-saw-you" channel name
//
// Author:
//   Anthony Liu, wiredfool, patcon@gittip

// helpers
function bind(fn, context) {
  return function() {
    return fn.apply(context, arguments);
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
    var username = msg.message.user.name;
    if (this.isPictureMessage(msg)) {
      this.robot.logger.debug('isawyou.add #{username}');
      if (this.cache.hasOwnProperty(username)) {
        this.cache[username] += 1;
      } else {
        this.cache[username] = 1;
      }
    }
  }

  // sets username's points to newPoints
  set(username, newPoints) {
    this.cache[username] = newPoints;
  }

  // returns the specific user's count
  getCount(username) {
    this.robot.logger.debug('isawyou.get #{username}');
    if (this.cache.hasOwnProperty(username)) {
      return this.cache[username];
    } else {
      return 0;
    }
  }

  // returns true iff the message is a picture message
  isPictureMessage(msg) {
    return msg.message.rawMessage.subtype === this.SUBTYPE;
  }
}

module.exports = function(robot) {
  'use strict';

  // config
  var config = require('hubot-conf')('isawyou', robot);

  // working variables
  var iSawYou = new ISawYou(robot);

  // update i-saw-you counts
  robot.hear(/.*/, function(msg) {
    // only listen to messages in the #i-saw-you channel
    if (config('room') === msg.message.room) {
      iSawYou.add(msg);
    }
  });

  // respond to i-saw-you queries
  robot.respond(
    /isawyou @?([-\w.\\^|{}`\[\]]+)$/,
    function(msg) {
      var username = msg.match[1];
      var count = iSawYou.getCount(username);
      msg.send('*' + username + '* has ' + count + ' i-saw-you points.');
    }
  );

  // respond to point set requests
  robot.respond(
    /isawyou set @?([-\w.\\^|{}`\[\]]+) (\d+)/,
    function(msg) {
      if (msg.match.length < 3) {
        msg.send('Usage: hackbot isawyou set <user> <number>');
      } else {
        var username = msg.match[1];
        var newPoints = parseInt(msg.match[2]);
        iSawYou.set(username, newPoints);
        msg.send('*' + username + '* now has ' + newPoints + ' i-saw-you points.');
      }
    }
  );
};