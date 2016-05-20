# Description:
#   Generates help commands for Hubot.
#
# Commands:
#   hubot help - Display all hubot commands.
#   hubot help <query> - Displays all hubot commands that match <query>.
#
# Notes:
#   These commands are grabbed from comment blocks at the top of each file.

module.exports = (robot) ->
    robot.respond /help(?: (\w*))?/i, (msg) ->
        commands = robot.helpCommands()
        search = msg.match[1]

        if search
            commands = commands.filter (command) ->
                command.match new RegExp(search, 'i')

            if commands.length == 0
                msg.send "No commands matching \"#{search}.\""
                return

        commands = commands.map (command) ->
            command = command.replace /^hubot/, robot.name
            command = command.replace /hubot/ig, "Slackerbot"
            command = command.replace /\s*-\s*/, "`\n"
            return "`#{command}"

        msg.send commands.join("\n\n")


    robot.router.get "/#{robot.name}/help", (req, res) ->
        cmds = robot.helpCommands().map (cmd) ->
            cmd.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')

        emit = "<p>#{cmds.join '</p><p>'}</p>"

        emit = emit.replace /hubot/ig, "<b>#{robot.name}</b>"

        res.setHeader 'content-type', 'text/html'
        res.end helpContents robot.name, emit
