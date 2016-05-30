# Description:
#   Keep track of named counters.
#
# Commands:
#   hubot set <counter> to <value> - Set the value of a counter, or create a new counter.
#   hubot get <counter> - Display the current value of a counter.
#   hubot add <value> to <counter> - Add <value> to the current value of a counter.
#   hubot subtract <value> from <counter> - Subtract <value> from the curent value of a counter.

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


    robot.respond /get ([a-zA-Z_][a-zA-Z0-9_]*)/i, (msg) ->
        name = msg.match[1]
        
        # Retrieve the counters from memory.
        counters = robot.brain.get 'counters'

        # Get the value of the requested counter, checking that the object
        # actually exists first.
        value = counters[name] if counters

        # Display the value, or an error if it is null.
        if value
            msg.send "#{name} is currently set to #{value}."
        else
            msg.send "#{name} is not defined."


    robot.respond /add (-?[0-9]+\.?[0-9]*) (?:to )?([a-zA-Z_][a-zA-Z0-9_]*)/i, (msg) ->
        operand = parseFloat msg.match[1]
        name = msg.match[2]

        # Refuse to add a negative number, to teach people about add and subtract.
        if operand < 0
            operand = 0 - operand
            msg.send "I can't add a negative value to a counter. Use `#{robot.name} subtract #{operand} from #{name}` instead."
            return

        # Get the current counters object.
        counters = robot.brain.get 'counters'

        if counters
            # Get the current value of the counter.
            value = counters[name]

            # Add the operand to the current value, as long as the counter exists.
            if value?
                newValue = value + operand
                counters[name] = newValue

            # Store the object back in memory.
            robot.brain.set 'counters', counters

        # Display the new value of the counter.
        if newValue
            msg.send "#{name} is now set to #{newValue}."
        else
            msg.send "#{name} is not defined."


    robot.respond /sub(?:tract)? (-?[0-9]+\.?[0-9]*) (?:from )?([a-zA-Z_][a-zA-Z0-9_]*)/i, (msg) ->
        operand = parseFloat msg.match[1]
        name = msg.match[2]

        # Refuse to subtract a negative number, to teach people about add and subtract.
        if operand < 0
            operand = 0 - operand
            msg.send "I can't subtract a negative value from a counter. Use `#{robot.name} add #{operand} to #{name}` instead."
            return

        # Get the current counters object.
        counters = robot.brain.get 'counters'

        if counters
            # Get the current value of the counter.
            value = counters[name]

            # Subtract the operand from the current value, as long as the counter exists.
            if value?
                newValue = value - operand
                counters[name] = newValue

            # Store the object back in memory.
            robot.brain.set 'counters', counters

        # Display the new value of the counter.
        if newValue
            msg.send "#{name} is now set to #{newValue}."
        else
            msg.send "#{name} is not defined."
