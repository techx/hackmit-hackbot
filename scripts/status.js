// Description:
//   Quick test to see if hubot is alive.
//
// Dependencies:
//   None
//
// Configuration:
//   None
//
// Author:
//   Detry322
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
module.exports = robot =>
  robot.router.get("/status/ping", (req, res) =>
    res.header("Content-Type", "text/plain").send("Pong!")
  );
