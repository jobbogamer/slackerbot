# Description:
#   Subscribe to YouTube playlists and videos from specific users matching filters.
#
# Commands:
#   hubot subscribe to <username> [matching <filter>] - Get notified about a channel's new YouTube videos, optionally only those with titles matching <filter>.
#   hubot unsubscribe from <username> [matching <filter>] - Stop getting notifications about a channel's videos.

pubsubhubbub = require('pubsubhubbub')

module.exports = (robot) ->

    port = process.env.EXPRESS_PORT
    hubUrl = "http://pubsubhubbub.appspot.com/"
    youtubeUserUrl = "https://youtube.com/feeds/videos.xml?user="
    youtubeChannelUrl = "https://www.youtube.com/feeds/videos.xml?channel_id="

    pubsub = pubsubhubbub.createServer {
        callbackUrl: "http://slackerbot.joshasch.com:#{port}"
    }

    pubsub.listen(port)

    
    pubsub.on 'denied', (err) ->
        robot.logger.error "pubsubhubbub subscription denied: #{JSON.stringify err}"


    pubsub.on 'error', (err) ->
        robot.logger.error "Error with pubsubhubbub: #{JSON.stringify err}"


    pubsub.on 'listen', ->
        robot.logger.info "pubsubhubbub server listening on port #{pubsub.port}"


    pubsub.on 'subscribe', (res) ->
        robot.logger.info "pubsubhubbub subscription successful"
        robot.logger.debug res


    pubsub.on 'unsubscribe', (res) ->
        robot.logger.info "pubsubhubbub successfully unsubscribed"
        robot.logger.debug res


    pubsub.on 'feed', (data) ->
        robot.logger.info "Feed data received from pubsubhubbub"
        robot.logger.debug data



    robot.respond /subscribe/, (msg) ->
        robot.logger.info "Subscribing..."
        pubsub.subscribe "http://testytestytestytestytesty.blogspot.com/feeds/posts/default", hubUrl


    robot.respond /unsubscribe/, (msg) ->
        pubsub.unsubscribe "http://testytestytestytestytesty.blogspot.com/feeds/posts/default", hubUrl
