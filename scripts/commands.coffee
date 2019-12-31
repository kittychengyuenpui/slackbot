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
#   HUBOT_AUTH_ADMIN - A comma separated list of user IDs
#
# Commands:
#   hubot hello - Say hello!
#   hubot !new members - link to procedure for new members.
#   hubot weather in <location> - Tells about the weather(temp, humidity, wind) in given location
#	hubot calendar [me] - Print out this month's calendar

welcomeMsg = ['Hello World!', 'Hello!', 'Hi~', 'Hey there']

module.exports = (robot) ->
	robot.hear /hello/i, (res) ->
		res.send res.random welcomeMsg
		
	robot.hear /!new members/i, (res) ->
		res.send "https://www.notion.so/dstarling/Click-me-if-you-like-being-informed-b5e1968173684dfd908f4a85c91ef6e7"
	
	child_process = require('child_process')
	robot.respond /calendar( me)?/i, (msg) ->
		child_process.exec 'cal -h', (error, stdout, stderr) ->
			if error
				msg.send stderr
				return
			msg.send(stdout)
   
 
 module.exports = (robot) ->
	robot.hear /weather in (.*)/i, (msg) ->
		city = msg.match[1]
		url = process.env.HUBOT_WEATHER_API_URL
		units = process.env.HUBOT_WEATHER_UNITS
		apiKey = process.env.HUBOT_OWM_APIKEY
		named_unit = switch
				when units == "metric" then "°C"
				when units == "imperial" then "°F"
				else  "K"
		msg.http(url + city + "&appid=" + apiKey + "&units=" + units).get() (err, res, body) ->
			if err
				res.send "Encountered an error :( #{err}"
				return
			data = JSON.parse(body)
			weather = [ "#{Math.round(data.main.temp)}#{named_unit}, humidity: #{data.main.humidity}%, wind: #{data.wind.speed}m/s" ]
			for w in data.weather
				weather.push w.description
			msg.reply "It's #{weather.join(', ')} in #{data.name}, #{data.sys.country}"
