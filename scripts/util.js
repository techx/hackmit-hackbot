// Description:
//   Utilities
//
// Author:
//   anishathalye
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS203: Remove `|| {}` from converted for-own loops
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const shallowClone = function(obj) {
  const copy = {};
  for (let key of Object.keys(obj || {})) {
    const value = obj[key];
    copy[key] = value;
  }
  copy.__proto__ = obj.__proto__; // not standard in ECMAScript, but it works
  return copy;
};

module.exports = function(robot) {
  const config = require("hubot-conf")("util", robot);

  robot.respond(/clear$/, res =>
    res.send(
      __range__(1, 60, true)
        .map(n => ".")
        .join("\n")
    )
  );

  if (robot.adapterName === "slack") {
    robot.logger.info("Adapter is slack: will terminate on client close");
    robot.adapter.client.on("close", () => process.exit(0));
  } else {
    robot.logger.info("Adapter is not slack, will not terminate on client close");
  }

  return robot.respond(/echo2 ((.*\s*)+)/i, res => res.send(res.match[1]));
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
