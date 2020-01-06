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
#   HUBOT_ADVICE_API_URL - API endpoint to get advice
#   HUBOT_ABSTRACT_API_URL - API endpoint of DuckDuckGo internet search engine to search abstract
#
# Commands:
#   hubot hello - Say hello!
#   hubot !new members - Get a link of procedure for new members.
#   hubot weather in <location> - Tells about the weather(temp, humidity, wind) in given location
#   hubot what should I do about <something> | what do you think about <something> | how do you handle <something> - Get advice about <something>
#   hubot advice - Get random advice
#   hubot abs | abstract - Prints a nice abstract of the given topic
#   hubot calc|calculate|calculator|math|maths [me] <expression> - Calculate the given math expression.
#   hubot convert <expression> in <units> - Convert expression to given units.
 
mathjs = require("mathjs")
welcomeMsg = ['Hello World!', 'Hello!', 'Hi~', 'Hey there']
getAdvice = (msg, query) ->
	url2 = process.env.HUBOT_ADVICE_API_URL
	msg.http(url2 + "/search/#{query}").get() (err, res, body) ->
		results = JSON.parse body
		if results.message? then randomAdvice(msg) else msg.send(msg.random(results.slips).advice)

randomAdvice = (msg) ->
	url2 = process.env.HUBOT_ADVICE_API_URL
	msg.http(url2).get() (err, res, body) ->
		results = JSON.parse body
		advice = if err then "You're on your own, bud" else results.slip.advice
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
				msg.send "Encountered an error :( #{err}"
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

	robot.respond /advice/i, (msg) ->
		randomAdvice msg
	
	robot.respond /(abs|abstract) (.*)/i, (res) ->
		url3 = process.env.HUBOT_ABSTRACT_API_URL
		abstract_url = url3 + res.match[2]
		res.http(abstract_url).header('User-Agent', 'Hubot Abstract Script').get() (err, _, body) ->
			if err
				res.send "Sorry, the tubes are broken." 
				return 
			data = JSON.parse(body)
			unless data?
				res.send "I don't know anything about that."
			if data.AbstractText
				res.send data.AbstractText
				if data.AbstractURL
					res.send data.AbstractURL 
			else if data.RelatedTopics and data.RelatedTopics.length
				topic = data.RelatedTopics[0]
				if topic and not /\/c\//.test(topic.FirstURL)
					res.send topic.Text
					res.send topic.FirstURL
			else if data.Definition
				res.send data.Definition
				if data.DefinitionURL
					res.send data.DefinitionURL 
			else
				res.send "I don't know anything about that."

	robot.respond /(calc|calculate|calculator|math|maths)( me)? (.*)/i, (msg) ->
		try
			result = mathjs.evaluate msg.match[3]
			if (result - mathjs.round(result, 3)) == 0
				msg.send "#{result}"
			else
				msg.send "#{mathjs.round(result, 3)} (correct to 3 significant figures)"
		catch error
			msg.send error.message || 'Could not compute.'
	
	robot.respond /convert (.*) in (.*)/i, (msg) ->
		try
			result = mathjs.to(mathjs.unit(msg.match[1]), msg.match[2])
			msg.send "#{result}"
		catch error
			msg.send error.message || 'Could not compute.'
			
	robot.respond /convert (cur|currency) (.*) to (.*)/i, (msg) ->
		url4 = process.env.HUBOT_CURRENCY_API_URL
		apiKey = process.env.HUBOT_CURRENCY_API_KEY
		msg.http(url4 + apiKey).get() (err, res, body) ->
			if err
				msg.send "Encountered an error :( #{err}"
				return
			data = JSON.parse(body)
			msg.reply "#{msg.match[2]} to  #{msg.match[3]} return: #{data}"