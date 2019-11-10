// Description:
//   Fun responses
//
// Author:
//   anishathalye

module.exports = (robot) => {
  const react = (emoji, res) => {
    if (robot.adapterName === 'slack') {
      return robot.emit('slack.reaction', {
        message: res.message,
        name: emoji,
      });
    }
    return res.send(`(react :${emoji}:)`);
  };

  const lennySnakeParts = [
    '╚═( ͡° ͜ʖ ͡°)═╝',
    '╚═(███)═╝',
    '╚═(███)═╝',
    '.╚═(███)═╝',
    '..╚═(███)═╝',
    '…╚═(███)═╝',
    '…╚═(███)═╝',
    '..╚═(███)═╝',
    '.╚═(███)═╝',
    '╚═(███)═╝',
    '.╚═(███)═╝',
    '..╚═(███)═╝',
    '…╚═(███)═╝',
    '…╚═(███)═╝',
    '…..╚(███)╝',
    '……╚(██)╝',
    '………(█)',
    '……….*',
  ];

  const lennySnakeTick = 300; // milliseconds

  robot.hear(/lenny(snake|pede)/i, (res) => {
    const sendFrom = (i) => {
      if (i < lennySnakeParts.length) {
        res.send(lennySnakeParts[i]);
        setTimeout(sendFrom, lennySnakeTick, i + 1);
      }
    };
    sendFrom(0);
  });

  robot.hear(/jason/i, (res) => {
    // make this less spammy
    if (Math.random() < 0.4) {
      if (Math.random() < 0.5) {
        react('upvote', res);
      } else {
        react('no_wifi', res);
      }
    }
  });

  robot.hear(/fun/i, (res) => {
    if (Math.random() < 0.3) {
      react('puzzled', res);
    }
  });

  robot.hear(/michael/i, (res) => {
    // make this less spammy
    if (Math.random() < 0.05) {
      react('silverman', res);
    }
  });

  // match basically any 100-char-long english sentence
  robot.hear(/e/i, (res) => {
    // make this less spammy
    if (res.message.text.length > 100 && Math.random() < 0.001) {
      res.send("whoa whoa guys are we sure that's a good idea?");
    }
  });

  robot.hear(/work/i, (res) => {
    if (res.message.text.length > 50 && Math.random() < 0.1) {
      res.send("It's not work it's Datto");
    }
  });

  const dootDoot = `\`\`\`
thank mr skeltal

░░░░░░░░░░░▐▄▐
░░░░░░▄▄▄░░▄██▄
░░░░░▐▀█▀▌░░░░▀█▄
░░░░░▐█▄█▌░░░░░░▀█▄
░░░░░░▀▄▀░░░▄▄▄▄▄▀▀
░░░░▄▄▄██▀▀▀▀
░░░█▀▄▄▄█░▀▀
░░░▌░▄▄▄▐▌▀▀▀
▄░▐░░░▄▄░█░▀▀
▀█▌░░░▄░▀█▀░▀
░░░░░░░▄▄▐▌▄▄
░░░░░░░▀███▀█░▄
░░░░░░▐▌▀▄▀▄▀▐▄
░░░░░░▐▀░░░░░░▐▌
░░░░░░█░░░░░░░░█
░░░░░▐▌░░░░░░░░░█
░░░░░█░░░░░░░░░░▐▌
\`\`\``;

  robot.hear(/(dootdootdoot|[0-9]spooky)/i, (res) => res.send(dootDoot));

  robot.hear(/(^|\b)a+y+ l[mfao]+($|\b)/i, (res) => res.send(':alien: ayy lmao :alien:'));

  const pusheens = [
    'http://i.imgur.com/ozA8GSu.png',
    'http://i.imgur.com/ZKQc2Zr.png',
    'http://i.imgur.com/4kYoLqW.png',
    'http://i.imgur.com/RrLH94y.png',
    'http://i.imgur.com/frlzb8j.png',
    'http://i.imgur.com/CrlTN9g.png',
    'http://i.imgur.com/T3aU0jE.png',
    'http://i.imgur.com/WVNB0AI.png',
    'http://i.imgur.com/MgURast.png',
    'http://i.imgur.com/h0WeeGt.png',
    'http://i.imgur.com/5Gaquu2.png',
    'http://i.imgur.com/KBRkat2.png',
    'http://i.imgur.com/2DA3pUj.png',
    'http://i.imgur.com/zbkwKyo.png',
    'http://i.imgur.com/ZjxGDGu.png',
    'http://i.imgur.com/2fM3Llu.png',
    'http://i.imgur.com/vmBTVZT.png',
    'http://i.imgur.com/LM4RhiD.png',
    'http://i.imgur.com/GsA3vF8.png',
    'http://i.imgur.com/SRlVsQl.png',
  ];

  robot.hear(/pusheen/i, (res) => res.send(res.random(pusheens)));

  robot.hear(/\btfti\b/, (res) => {
    if (Math.random() < 0.2) {
      res.send('tfti');
    }
  });

  robot.hear(/^same$/, (res) => {
    if (Math.random() < 0.4) {
      res.send('same');
    }
  });

  const selfDestructSequence = [
    'Initiating HackMIT self-destruct sequence...',
    '10: Leaking sponsorship info...',
    '9: Insulting all previous company contacts...',
    '8: Transferring funds to FCF...',
    '7',
    '6: Destroying all AWS instances...',
    '5: ',
    '4: Dropping reg DB...',
    '3',
    '2',
    "1: You've met with a terrible fate, haven't you?",
    'http://rs651.pbsrc.com/albums/uu236/416o/explosion.gif~c200',
  ];

  const selfDestructTick = 1000; // milliseconds

  robot.respond(/selfdestruct/i, (res) => {
    const sendFrom = (i) => {
      if (i < selfDestructSequence.length) {
        res.send(selfDestructSequence[i]);
        setTimeout(sendFrom, selfDestructTick, i + 1);
      }
    };
    sendFrom(0);
  });
};
