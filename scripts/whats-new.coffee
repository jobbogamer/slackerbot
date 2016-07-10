# Description:
#   Fetches the release notes from GitHub for the latest release of the bot.
#
# Commands:
#   hubot what's new - Show release notes for the latest version of the bot.
#
# Configuration:
#   HUBOT_GITHUB_REPO_OWNER - Username of the bot's GitHub repo owner.
#   HUBOT_GITHUB_REPO_NAME  - Name of the bot's GitHub repo.


GitHub = require('github')

# Get the latest release from GitHub and return the body text.
getReleaseNotes = (robot, callback) ->
    github = new GitHub {
        version: "3.0.0",
        protocol: "https",
        timeout: 5000,
        headers: {
            "user-agent": "slackerbot"
        }
    }

    options = {
        owner: process.env.HUBOT_GITHUB_REPO_OWNER,
        repo: process.env.HUBOT_GITHUB_REPO_NAME
    }

    # Get all releases for the repo.
    github.releases.listReleases options, (err, res) ->
        if err
            robot.logger.error "whats-new.coffee: #{JSON.stringify err}"
            callback()
            return

        if not res?
            robot.logger.error "whats-new.coffee: No object returned in listReleases callback"
            callback()
            return

        current_version = require('../package.json').version

        # Loop through all returned releases looking for the latest one.
        for release in res
            # Find the release that matches the current package version.
            if release.tag_name?
                if release.tag_name is "v#{current_version}"
                    if release.body?
                        callback release.body
                        return
                    else
                        robot.logger.error "whats-new.coffee: Release object no longer contains 'body'"
                        callback()
                        return
            else
                robot.logger.error "whats-new.coffee: Release object no longer contains 'tag_name'"
                callback()
                return

        # If this point is reached, none of the tag names matched the current
        # version number.
        robot.logger.warning "whats-new.coffee: No tag found matching the current version number"
        callback()
        return
        


module.exports = (robot) ->

    robot.respond /what(?:'|’)s new/i, (msg) ->
        getReleaseNotes robot, (notes) ->
            if notes?
                msg.send notes
            else
                msg.send "I couldn't fetch the latest release notes."
