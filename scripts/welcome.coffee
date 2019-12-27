# Description:
#   To welcome new members to the community
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:

module.exports = (robot) ->
  robot.enter (res) ->
    res.reply "Welcome, *#{res.message.user.name}*! :wave:"
	
