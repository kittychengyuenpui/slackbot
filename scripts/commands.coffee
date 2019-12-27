# Description:
#   To demonstrate basic keyword commands
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_WEATHER_API_URL - Optional openweathermap.org API endpoint to use
#   HUBOT_WEATHER_UNITS - Temperature units to use. 'metric' or 'imperial'
#   HUBOT_OWM_APIKEY - APIKEY to obtain weather info from OWM API
#
# Commands:
#   hubot hello - Say hello!
#   hubot !new members - link to procedure for new members.
#   hubot weather in <location> - Tells about the weather in given location
#	hubot calendar [me] - Print out this month's calendar

welcomeMsg = ['Hello World!', 'Hello!', 'Hi~', 'Hey there']

module.exports = (robot) ->
	robot.hear /hello/i, (res) ->
		res.send res.random welcomeMsg
		
	robot.hear /!new members/i, (res) ->
		res.send "https://www.notion.so/dstarling/Click-me-if-you-like-being-informed-b5e1968173684dfd908f4a85c91ef6e7"
	
	child_process = require('child_process')
	robot.respond /calendar( me)?/i, (res) ->
		child_process.exec 'cal -h', (error, stdout, stderr) ->
		res.send(stdout)
	
	process.env.HUBOT_WEATHER_API_URL ||=
   'http://api.openweathermap.org/data/2.5/weather'
 process.env.HUBOT_WEATHER_UNITS ||= 'imperial'
 
 module.exports = (robot) ->
   robot.hear /weather in (\w+)/i, (res) ->
     city = res.match[1]
     query = { units: process.env.HUBOT_WEATHER_UNITS, q: city, appid: process.env.HUBOT_OWM_APIKEY}
     url = process.env.HUBOT_WEATHER_API_URL
     res.robot.http(url).query(query).get() (err, res, body) ->
       data = JSON.parse(body)
       weather = [ "#{Math.round(data.main.temp)} degrees" ]
       for w in data.weather
         weather.push w.description
       res.reply "It's #{weather.join(', ')} in #{data.name}, #{data.sys.country}"