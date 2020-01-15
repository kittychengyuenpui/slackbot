# slackbot2 ![Hubot image on slack](https://a.slack-edge.com/80588/img/services/hubot_512.png){:height="50%" width="50%"} 

slackbot2 is a chat bot built on the [Hubot][hubot] framework and run on Slack. It was
initially generated by [generator-hubot][generator-hubot], and configured to be
deployed on [Heroku][heroku].



[heroku]: http://www.heroku.com
[hubot]: http://hubot.github.com
[generator-hubot]: https://github.com/github/generator-hubot

### Running slackbot2 Locally

You can test your hubot by running the following, however some plugins will not
behave as expected unless the [environment variables](#configuration) they rely
upon have been set.

Starting slackbot2 locally by running:
	
    HUBOT_SLACK_TOKEN=APP-TOKEN-GENERATED-BY-SLACK ./bin/hubot --adapter slack
	
You'll see some start up output and a prompt:

    [Sat Feb 28 2015 12:38:27 GMT+0000 (GMT)] INFO Using default redis on localhost:6379
    slackbot2>

Then you can interact with slackbot2 by typing `slackbot2 help`.

    slackbot2> slackbot2 help
    slackbot2 help - Displays all of the help commands that slackbot2 knows about.
    ...

### Configuration

	1. It runs on Slack
	2. It wakes at 09:30 and sleeps at 23:00 (managed by heroku scheduler add-on)
	3. It uses openWeatherMap API for weather information
	4. It uses adviceslip API for advice
	5. It uses fixer API for latest currency exchange rate
	6. It uses holiday API to check holidays every day at 11am automatically

### Scripting

	1. example.coffee
	2. commands.coffee
	3. welcome.coffee
	
Commands set in commands.coffee:
Hubot Commands | Explanation
-------------- | -----------
hubot hello | Say hello!
hubot !new members | Get a link of procedure for new members
hubot weather in <location> | Get weather information(including temperature, humidity, wind) in given location
hubot what should I do about <something> / what do you think about <something> / how do you handle <something> | Get advice about <something>   
hubot advice | Get random advice 
hubot abs/abstract | Prints a nice abstract of the given topic
hubot calc/calculate/calculator/math/maths [me] <expression> | Calculate the given math expression
hubot convert <expression> in <units> | Convert expression to given units
hubot cur/currency <currency 1> to <currency 2> | Get the latest currency exchange rate from currency 1 to currency 2 (currency 1 as base)

* View more by typing `slackbot2 help`	

### external-scripts (hubot plugins)

	hubot-diagnostics
	hubot-help
	hubot-heroku-keepalive
	hubot-google-images
	hubot-pugme
	hubot-maps
	hubot-redis-brain
	hubot-rules
	hubot-shipit
	hubot-env
	hubot-auth
	hubot-ascii-art

## Deployment

	1. Deployed on Heroku
	2. App Name: slackbot2-1661

## Restart the bot

You may want to get comfortable with `heroku logs` and `heroku restart` if
you're having issues.
