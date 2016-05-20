# Description:
#   Code that runs when Slackerbot first starts.

module.exports = (robot) ->

    # Whether the startup script has been called or not.
    @startupFinished = false


    # Event emitted once the brain has loaded and the version number has been
    # extracted from package.json.
    robot.on 'startup', ->
        robot.logger.info 'Slackerbot has started'

    
    # Event emitted when the brain is loaded from Redis.
    robot.brain.on 'loaded', ->
        if not @startupFinished
            # Stop the startup script from executing multiple times.
            @startupFinished = true

            # Get the slackerbot version number from package.json and compare it
            # to the version in the brain.
            pkg = require('../package.json')
            currentVersion = pkg.version
            brainVersion = robot.brain.get 'version'

            robot.logger.info "Slackerbot version #{currentVersion}"
            robot.logger.info "Hubot version #{robot.version}"
            robot.logger.debug "Version stored in brain was #{brainVersion}"

            # If the current version is different to the version from the brain,
            # send a message to #general saying that slackerbot has been updated.
            if currentVersion != brainVersion
                robot.messageRoom "general", "Slackerbot has been updated to version #{currentVersion}."
                robot.brain.set 'version', currentVersion

            # Emit the startup event.
            robot.emit 'startup'    
