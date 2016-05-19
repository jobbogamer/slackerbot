# Description:
#   Keep track of named counters.
#
# Commands:
#   hubot set <name> to <value> - Set the value of a counter, or create a new counter
#   hubot get <name> - Display the current value of a counter
#   hubot add <value> to <name> - Add <value> to the current value of a counter
#   hubot subtract <value> from <name> - Subtract <value> from the curent value of a counter

module.exports = (robot) ->

    robot.respond /set ([a-zA-Z_][a-zA-Z0-9_]*) to (-?[0-9]+\.?[0-9]*)/i, (msg) ->
        name = msg.match[1]
        value = parseFloat msg.match[2]

        # If the counters object doesn't exist, create it.
        if not robot.brain.get('counters')
            robot.brain.set 'counters', {}

        # Get the current counters object.
        counters = robot.brain.get 'counters'

        # Set the new value.
        counters[name] = value

        # Store the object back in memory.
        robot.brain.set 'counters', counters

        # Display the new value of the counter.
        msg.send "#{name} is now set to #{value}."
