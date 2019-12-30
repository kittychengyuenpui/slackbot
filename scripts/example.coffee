# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

module.exports = (robot) ->

  robot.respond /open the (.*) doors/i, (res) ->
    doorType = res.match[1]
    if doorType is "pod bay"
      res.reply "I'm afraid I can't let you do that."
    else
      res.reply "Opening #{doorType} doors"
 
  robot.hear /I like pie/i, (res) ->
    res.emote ":yum:Makes a freshly baked pie! :pie:"

  messages = ['Merry Christmas!:christmas_tree:', 'Merry Xmas!:gift:', 'Last Christmas I gave you my heart~:musical_note:', ':santa:Santa Claus is coming to town~']
  
  robot.hear /christmas/i, (res) ->
    res.send res.random messages
	
  robot.topic (res) ->
    res.send "#{res.message.text}? Sounds interesting'"

  leaveReplies = ['Are you still there?', 'Target lost...', 'See you~', 'Bye~']
  robot.leave (res) ->
    res.send res.random leaveReplies
  #
  #
  # answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING
  #
  # robot.respond /what is the answer to the ultimate question of life/, (res) ->
  #   unless answer?
  #     res.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in environment: please set and try again"
  #     return
  #   res.send "#{answer}, but what is the question?"
  #
  robot.respond /you are slow/, (res) ->
    setTimeout () ->
      res.send "Who are you calling 'slow'?!"
    , 60 * 1000
  #
  # annoyIntervalId = null
  #
  # robot.respond /annoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #     return
  #
  #   res.send "Hey, want to hear the most annoying sound in the world?"
  #   annoyIntervalId = setInterval () ->
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #   , 1000
  #
  # robot.respond /unannoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "GUYS, GUYS, GUYS!"
  #     clearInterval(annoyIntervalId)
  #     annoyIntervalId = null
  #   else
  #     res.send "Not annoying you right now, am I?"
  #
  #
  robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
    room   = req.params.room
    data   = JSON.parse req.body.payload
    secret = data.secret

    robot.messageRoom room, "I have a secret: #{secret}"
 
    res.send 'OK'

  robot.error (err, res) ->
    robot.logger.error "DOES NOT COMPUTE 1"
 
    if res?
      res.reply err
  
  robot.respond /have a soda/i, (res) ->
    # Get number of sodas had (coerced to a number).
    sodasHad = robot.brain.get('totalSodas') * 1 or 0
 
    if sodasHad > 5
      res.reply "I'm too fizzy..."
 
    else
      res.reply ':cup_with_straw:'
 
      robot.brain.set 'totalSodas', sodasHad+1
 
  robot.respond /sleep it off/i, (res) ->
    robot.brain.set 'totalSodas', 0
    res.reply ':sleeping:'

  # A map of user IDs to scores
  thank_scores = {}

  robot.hear /thanks/i, (res) ->
    # filter mentions to just user mentions
    user_mentions = (mention for mention in res.message.mentions when mention.type is "user")

    # when there are user mentions...
    if user_mentions.length > 0
      response_text = ""

      # process each mention
      for { id } in user_mentions
        # increment the thank score
        thank_scores[id] = if thank_scores[id]? then (thank_scores[id] + 1) else 1
        # show the total score in the message with a properly formatted mention (uses display name)
        response_text += "<@#{id}> has been thanked #{thank_scores[id]} times!\n"

      # send the response
      res.send response_text
	  