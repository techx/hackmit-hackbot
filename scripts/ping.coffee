# Description
#   Ping all the members of a committee by ping that committee
#
# Author:
#   mysticuno

# Attempt to define committees
logs = ['carlosh', 'jasonma', 'jjz', 'kimberli', 'lisa', 'rotemh', 'sabrina', 'zareenc', 'zhangbanger']
finance = ['carlosh', 'afmartin', 'jasonma', 'jennyu', 'jjz', 'kimberli', 'sabrina']
marketing = ['vervious', 'atguo', 'chialiu', 'jmfessy', 'larryzhang', 'ehzhang', 'jjz', 'kimberli']
cr = ['carlosh', 'jasonma', 'jjz', 'kimberli', 'ehzhang', 'jack.serrino', 'pan18m', 'rotemh', 'sabrina', 'zareenc', 'zhangbanger', 'vonolden']
dev = ['anish', 'ehzhang', 'trujano', 'larryzhang', 'kate', 'jack.serrino', 'jjz', 'kimberli']

committees = {'logs': logs, 'logistics': logs, 'dev': dev, 'marketing', marketing, 'mkt': marketing, 'cr':cr, 'fin':finance, 'finance':finance}

# Ping everyone on the committee
ping = (com) ->
	if com not in committees
		res.send "Sorry, I'm afraid we dont have a #{com} committee"
	else
		members = committees[com]
		msg = "Ping"
		for mem in members
			msg += " @#{mem}"
		res.send msg

module.exports = (robot) ->

	robot.respond /ping (@)?(.*)/i, (res) ->
		com = res.match[1]
		ping com
