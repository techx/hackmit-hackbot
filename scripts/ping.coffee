# Description
#   Ping all the members of a committee by ping that committee
#
# Commands:
#   hubot ping @<committee> - Pings everyone on the committee
#
# Author:
#   mysticuno

Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output

# Attempt to define committees
heads = ['kimberli', 'jjz']
logs = ['carlosh', 'jasonma', 'jjz', 'kimberli', 'lisa', 'rotemh', 'sabrina', 'zareenc', 'zhangbanger']
finance = ['carlosh', 'afmartin', 'jasonma', 'jennyu', 'jjz', 'kimberli', 'sabrina']
marketing = ['vervious', 'atguo', 'chialiu', 'jmfessy', 'larryzhang', 'ehzhang', 'jjz', 'kimberli']
cr = ['carlosh', 'jasonma', 'jjz', 'kimberli', 'ehzhang', 'pan18m', 'rotemh', 'sabrina', 'zareenc', 'zhangbanger', 'vonolden']
dev = ['anish', 'ehzhang', 'trujano', 'larryzhang', 'kate', 'jackserrino', 'jjz', 'kimberli']
test = ['hackbot', 'slackbot']

committees = {
	'heads': heads,
	'logs': logs,
	'logistics': logs,
	'dev': dev,
	'marketing', marketing,
	'mkt': marketing,
	'cr':cr,
	'fin':finance,
	'finance':finance,
	'test': test,
	'all': [heads..., logs..., finance..., marketing..., cr..., dev...].unique()
}

# Ping everyone on the committee
ping = (com, res) ->
	if not committees[com]
		res.send "Sorry, I'm afraid we don't have a `#{com}` committee."
	else
		members = committees[com]
		msg = "Ping"
		for mem in members
			msg += " <@#{mem}>"
		res.send msg

module.exports = (robot) ->

	robot.respond /ping @?(.*)$/i, (res) ->
		com = res.match[1].replace("@","")
		ping com, res
