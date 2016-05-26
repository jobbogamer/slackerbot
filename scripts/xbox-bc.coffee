# Description:
#   Check Major Nelson's backwards compatibility page to see if new games have been added.

CronJob = require('cron').CronJob
cheerio = require('cheerio')

url = 'https://majornelson.com/blog/xbox-one-backward-compatibility/'

module.exports = (robot) ->

    # Fetch the list of backwards-compatible games and return them as an array.
    fetchList = (callback) ->
        robot.http(url).get() (err, res, body) ->
            if err
                robot.logger.error "Couldn't fetch backward compatible games: #{JSON.stringify err}"
                callback []
            else
                $ = cheerio.load body
                list = []

                $('table').find('tbody').find('tr').each (i, row) ->
                    list.push $(row).find('td').find('a').text()

                callback list


    # The function to run when the cron job executes.
    cronFunction = () ->
        robot.logger.info "Checking for new Xbox backwards compatibility games..."
        # Get current list of known games from the database.
        oldList = (robot.brain.get 'xbox_bc_list') or []

        # Get the new list from the site.
        fetchList (games) ->
            # Extract just the new games from the list.
            newGames = games.filter (game) ->
                return not (game in oldList)

            if newGames.length isnt 0
                # Send the list of new games to #general.
                unit = if newGames.length is 1 then '' else 's'
                message = "New game#{unit} added to Xbox One backwards compatibility:\n• #{newGames.join '\n• '}"
                robot.messageRoom 'general', message

                # Store the new list of games in the database.
                robot.brain.set 'xbox_bc_list', newGames

            else
                robot.logger.info "No new backwards compatible games found"


    # Once the robot has started up, start a cron job to check the page every day.
    robot.on 'startup', ->
        # Run the job every day at 15:00:00.
        job = new CronJob '00 00 15 * * *', cronFunction, null, true, 'Europe/London'
        robot.logger.info 'Started xbox-bc cron job'
