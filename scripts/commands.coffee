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
#   HUBOT_ADVICE_API_URL - API endpoint of Advice Slip
#   HUBOT_ABSTRACT_API_URL - API endpoint of DuckDuckGo internet search engine to search abstract
#   HUBOT_CURRENCY_API_KEY - API key to obtain currency rate from Fixer API
#   HUBOT_CURRENCY_API_URL - API endpoint of Fixer
#   HUBOT_HOLIDAY_API_KEY - API key to check holiday
#   HUBOT_HOLIDAY_API_URL - API endpoint of Calendarific
#   HUBOT_NEWS_API_KEY - API key to search latest news if today is a holiday
#   HUBOT_NEWS_API_URL - endpoint of News API
#
# Commands:
#   hubot hello - Say hello!
#   hubot !new members - Get a link of procedure for new members.
#   hubot weather in <location> - Get weather information(including temperature, humidity, wind) in given location
#   hubot what should I do about <something> | what do you think about <something> | how do you handle <something> - Get advice about <something>
#   hubot advice - Get random advice
#   hubot abs | abstract - Prints a nice abstract of the given topic
#   hubot calc|calculate|calculator|math|maths [me] <expression> - Calculate the given math expression.
#   hubot convert <expression> in <units> - Convert expression to given units.
#   hubot cur | currency <currency 1> to <currency 2> - Get the latest currency exchange rate from currency 1 to currency 2 (currency 1 as base)
#   hubot news <query> - search the latest news of the query

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

everyDayCheckHoliday = (robot, year, month, day) ->	
	->	robot.http(process.env.HUBOT_HOLIDAY_API_URL + "api_key=" + process.env.HUBOT_HOLIDAY_API_KEY + "&country=HK&year=" + year + "&month=" + month + "&day=" + day).get() (err, res, body) -> 
			results = JSON.parse body
			if err  
				robot.messageRoom "#general", "Encountered an error :( #{err}"
				return
			unless results.response.holidays.length 
				robot.messageRoom "#general", "Today is not a holiday." 
			else
				robot.messageRoom "#general", "Today is #{year}-#{month}-#{day} #{results.response.holidays[0].name}! :tada:"
				url = process.env.HUBOT_NEWS_API_URL
				apiKey = process.env.HUBOT_NEWS_API_KEY
				robot.http(url + "top-headlines?country=hk&apiKey=" + apiKey + "&q=" + results.response.holidays[0].name).get() (err, res, body) -> 
					if err
						robot.messageRoom "#general", "Encountered an error :( #{err}"
						return
					results2 = JSON.parse body
					if results2.totalResults == 0 
						robot.messageRoom "#general", "No result"
					else
						randNum = Math.floor(Math.random() * ((results2.totalResults - 1) - 0) + 0)
						robot.messageRoom "#general", results2.articles[randNum].url
						robot.messageRoom "#general", "Published at: #{results2.articles[randNum].publishedAt.split('T')[0]}" 
						robot.messageRoom "#general", "Powered by <https://newsapi.org|News API> "
				#getNews2 robot, "#general", results.response.holidays[0].name

getNews = (msg, query) ->
	url = process.env.HUBOT_NEWS_API_URL
	apiKey = process.env.HUBOT_NEWS_API_KEY
	msg.http(url + "top-headlines?country=hk&apiKey=" + apiKey + "&q=" + query).get() (err, res, body) -> 
		if err
			msg.send "Encountered an error :( #{err}"
			return
		results = JSON.parse body
		if results.totalResults == 0 
			msg.send "No result"
		else
			randNum = Math.floor(Math.random() * ((results.totalResults - 1) - 0) + 0)
			msg.send(results.articles[randNum].url)
			msg.send("Published at: #{results.articles[randNum].publishedAt.split('T')[0]}") 
			msg.send("Powered by <https://newsapi.org|News API> ")

module.exports = (robot) ->
	#   hello/hubot hello - Say hello!
	robot.hear /hello/i, (res) ->
		res.send res.random welcomeMsg
	
	#   !new members/hubot !new members - Get a link of procedure for new members.
	robot.hear /!new members/i, (res) ->
		res.send process.env.HUBOT_NEW_MEMBERS_URL
	
	#   weather in <location>/hubot weather in <location> - Get weather information(including temperature, humidity, wind) in given location
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
	
	#   hubot what should I do about <something> | what do you think about <something> | how do you handle <something> - Get advice about <something>
	robot.respond /what (do you|should I) do (when|about) (.*)/i, (msg) ->
		getAdvice msg, msg.match[3]

	robot.respond /how do you handle (.*)/i, (msg) ->
		getAdvice msg, msg.match[1]

	robot.respond /(.*) some advice about (.*)/i, (msg) ->
		getAdvice msg, msg.match[2]

	robot.respond /(.*) think about (.*)/i, (msg) ->
		getAdvice msg, msg.match[2]

	#   hubot advice - Get random advice
	robot.respond /advice/i, (msg) ->
		randomAdvice msg
	
	#   hubot abs | abstract - Prints a nice abstract of the given topic
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

	#   hubot calc|calculate|calculator|math|maths [me] <expression> - Calculate the given math expression.
	robot.respond /(calc|calculate|calculator|math|maths)( me)? (.*)/i, (msg) ->
		try
			result = mathjs.evaluate msg.match[3]
			if (result - mathjs.round(result, 3)) == 0
				msg.send "#{result}"
			else
				msg.send "#{mathjs.round(result, 3)} (correct to 3 significant figures)"
		catch error
			msg.send error.message || 'Could not compute.'
	
	#   hubot convert <expression> in <units> - Convert expression to given units.
	robot.respond /convert (.*) in (.*)/i, (msg) ->
		try
			result = mathjs.to(mathjs.unit(msg.match[1]), msg.match[2])
			msg.send "#{result}"
		catch error
			msg.send error.message || 'Could not compute.'
	
	#   hubot cur | currency <currency 1> to <currency 2> - Get the latest currency exchange rate from currency 1 to currency 2 (currency 1 as base)	
	robot.respond /(cur|currency) (.*) to (.*)/i, (msg) ->
		url4 = process.env.HUBOT_CURRENCY_API_URL
		apiKey = process.env.HUBOT_CURRENCY_API_KEY
		msg.http(url4 + apiKey).get() (err, res, body) ->
			if err
				msg.send "Encountered an error :( #{err}"
				return
			data = JSON.parse(body)
			base = data.base
			index = base.localeCompare msg.match[2]
			if  index == 0
				toRate = msg.match[3]
				if !data['rates'][toRate]
					msg.send "No such currency: #{toRate}"
				else
					msg.send "1 #{msg.match[2]} :  #{data['rates'][toRate]} #{msg.match[3]}"
			else
				fromRate = msg.match[2]
				toRate = msg.match[3]
				if !data['rates'][fromRate]
					msg.send "No such currency: #{fromRate}"
				else if !data['rates'][toRate]
					msg.send "No such currency: #{toRate}"
				else
					resultRate = 1 / data['rates'][fromRate] * data['rates'][toRate]
					msg.send "1 #{msg.match[2]} :  #{resultRate} #{msg.match[3]}"
	
	#	Auto-check to see if today is a holiday using Holiday API at 11am every day
	cronJob = require('cron').CronJob
	now = new Date()
	year = now.getFullYear()
	month = now.getMonth() + 1
	day = now.getDate()
	new cronJob('0 10 12 * * *', everyDayCheckHoliday(robot, year, month, day), null, true, "Asia/Hong_Kong")
	
	#	Respond with the same emoji reaction when a emoji reaction is added
	robot.hearReaction (res) ->
		if res.message.type == "added" and res.message.item.type == "message"
			res.send ":#{res.message.reaction}:"
	
	#   hubot news <query> - search the latest news of the query
	robot.respond /news (.*)/i, (msg) -> 
		getNews msg, msg.match[1]
