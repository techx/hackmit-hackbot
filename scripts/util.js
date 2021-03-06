// Description:
//   Utilities
//
// Author:
//   anishathalye

let rangeFn;

module.exports = (robot) => {
  robot.respond(/clear$/, (res) => res.send(
    rangeFn(1, 60, true)
      .map(() => '.')
      .join('\n'),
  ));

  if (robot.adapterName === 'slack') {
    robot.logger.info('Adapter is slack: will terminate on client close');
    robot.adapter.client.on('close', () => process.exit(0));
  } else {
    robot.logger.info('Adapter is not slack, will not terminate on client close');
  }

  robot.respond(/echo2 ((.*\s*)+)/i, (res) => res.send(res.match[1]));
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
