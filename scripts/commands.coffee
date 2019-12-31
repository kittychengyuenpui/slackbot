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
#	HUBOT_NEW_MEMBERS_URL - A link for new members
#   HUBOT_ADVICE_API_URL - adviceslip JSON API endpoint
#
# Commands:
#   hubot hello - Say hello!
#   hubot !new members - link to procedure for new members.
#   hubot weather in <location> - Tells about the weather(temp, humidity, wind) in given location
#   hubot what should I do about <something> / what do you do when <something> / what do you think about <something> / how do you handle <something> / I want some advice about <something> - Get advice about <something>
#   hubot advice [me] - Get random advice

welcomeMsg = ['Hello World!', 'Hello!', 'Hi~', 'Hey there']

getAdvice = (msg, query) ->
	msg.http(process.env.HUBOT_ADVICE_API_URL + "/search/#{query}").get() (err, res, body) ->
		if err
			msg.send "Encountered an error :( #{err}"
			return
		results = JSON.parse(body)
		if results.message? 
			randomAdvice(msg) 
		else 
			msg.send(msg.random(results.slips).advice)

randomAdvice = (msg) ->
	msg.http(process.env.HUBOT_ADVICE_API_URL).get() (err, res, body) ->
		if err
			msg.send "Encountered an error :( #{err}"
			return
		results = JSON.parse(body)
		advice = results.slip.advice
		msg.send advice
			
module.exports = (robot) ->
	robot.hear /hello/i, (res) ->
		res.send res.random welcomeMsg
		
	robot.hear /!new members/i, (res) ->
		res.send process.env.HUBOT_NEW_MEMBERS_URL
   
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
	
	robot.respond /what (do you|should I) do (when|about) (.*)/i, (msg) ->
		getAdvice msg, msg.match[3]

	robot.respond /how do you handle (.*)/i, (msg) ->
		getAdvice msg, msg.match[1]

	robot.respond /(.*) some advice about (.*)/i, (msg) ->
		getAdvice msg, msg.match[2]

	robot.respond /(.*) think about (.*)/i, (msg) ->
		getAdvice msg, msg.match[2]

	robot.respond /advice( me)?/i, (msg) ->
		msg.http(process.env.HUBOT_ADVICE_API_URL).get() (err, res, body) ->
			if err
				msg.send "Encountered an error :( #{err}"
				return
			results = JSON.parse(body)
			advice = results.slip.advice
			msg.send advice